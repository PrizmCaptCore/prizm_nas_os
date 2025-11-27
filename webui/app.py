#!/usr/bin/env python3
"""
PRIZM NAS Web UI
Simple and fast NAS management interface with authentication
"""

from flask import Flask, render_template, jsonify, request, send_file, session, redirect, url_for
from werkzeug.security import check_password_hash, generate_password_hash
from werkzeug.utils import secure_filename
from functools import wraps
import subprocess
import json
import os

app = Flask(__name__)
app.secret_key = os.urandom(24)  # Random secret key for sessions

# Configuration
app.config['UPLOAD_FOLDER'] = '/srv/nas/uploads'
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024 * 1024  # 16GB max file size

# Create upload directory if it doesn't exist
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

# Default credentials (admin/admin) - should be changed on first login
# Password is hashed using werkzeug's generate_password_hash
DEFAULT_PASSWORD_HASH = generate_password_hash('admin')

def run_command(cmd):
    """Execute shell command and return output"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=5)
        return result.stdout.strip()
    except Exception as e:
        return f"Error: {str(e)}"

def login_required(f):
    """Decorator to require login for routes"""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'logged_in' not in session:
            # For API requests, return JSON error
            if request.path.startswith('/api/'):
                return jsonify({'error': 'Authentication required'}), 401
            # For page requests, redirect to login
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function


# ============================================
# Authentication Routes
# ============================================

@app.route('/login', methods=['GET', 'POST'])
def login():
    """Login page and authentication"""
    if request.method == 'POST':
        data = request.get_json()
        username = data.get('username', '')
        password = data.get('password', '')

        # Simple authentication (username: admin, password: admin by default)
        if username == 'admin' and check_password_hash(DEFAULT_PASSWORD_HASH, password):
            session['logged_in'] = True
            session['username'] = username
            return jsonify({'success': True})
        else:
            return jsonify({'error': 'Invalid credentials'}), 401

    return render_template('login.html')

@app.route('/logout')
def logout():
    """Logout and clear session"""
    session.clear()
    return redirect(url_for('login'))

# ============================================
# Main Dashboard
# ============================================

@app.route('/')
@login_required
def index():
    """Main dashboard"""
    return render_template('index.html')

# ============================================
# System Information APIs
# ============================================

@app.route('/api/system')
@login_required
def get_system_info():
    """Get system information"""
    hostname = run_command('hostname')
    uptime = run_command('uptime -p')
    kernel = run_command('uname -r')

    return jsonify({
        'hostname': hostname,
        'uptime': uptime,
        'kernel': kernel
    })

@app.route('/api/disks')
@login_required
def get_disks():
    """Get disk information"""
    lsblk = run_command('lsblk -J -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE')
    try:
        disks = json.loads(lsblk)
        return jsonify(disks)
    except:
        return jsonify({'error': 'Failed to get disk info'})

@app.route('/api/network')
@login_required
def get_network():
    """Get network information"""
    ip = run_command('ip -4 addr show | grep inet | grep -v 127.0.0.1')
    return jsonify({'interfaces': ip.split('\n')})

@app.route('/api/services')
@login_required
def get_services():
    """Get service status"""
    services = ['sshd', 'smbd', 'nfs-server', 'nas-webui']
    status = {}

    for svc in services:
        result = run_command(f'systemctl is-active {svc} 2>/dev/null || echo inactive')
        status[svc] = result

    return jsonify(status)


# ============================================
# File Management APIs
# ============================================

@app.route('/api/files/list')
@login_required
def list_files():
    """List files in upload directory"""
    try:
        files = []
        for filename in os.listdir(app.config['UPLOAD_FOLDER']):
            filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
            if os.path.isfile(filepath):
                stat = os.stat(filepath)
                files.append({
                    'name': filename,
                    'size': stat.st_size,
                    'modified': stat.st_mtime
                })
        return jsonify({'files': files})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/files/upload', methods=['POST'])
@login_required
def upload_file():
    """Upload a file"""
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400

    file = request.files['file']

    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400

    try:
        filename = secure_filename(file.filename)
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)

        if os.path.exists(filepath):
            return jsonify({'error': 'File already exists'}), 409

        file.save(filepath)
        return jsonify({
            'success': True,
            'filename': filename,
            'size': os.path.getsize(filepath)
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/files/download/<filename>')
@login_required
def download_file(filename):
    """Download a file"""
    try:
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], secure_filename(filename))
        if not os.path.exists(filepath):
            return jsonify({'error': 'File not found'}), 404

        return send_file(filepath, as_attachment=True)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/files/delete/<filename>', methods=['DELETE'])
@login_required
def delete_file(filename):
    """Delete a file"""
    try:
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], secure_filename(filename))
        if not os.path.exists(filepath):
            return jsonify({'error': 'File not found'}), 404

        os.remove(filepath)
        return jsonify({'success': True})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    # Run on all interfaces, port 80
    app.run(host='0.0.0.0', port=80, debug=False)
