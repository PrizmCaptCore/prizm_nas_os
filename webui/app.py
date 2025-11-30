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
app.config['BASE_FOLDER'] = '/srv/nas'  # Base folder for file browser
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024 * 1024  # 16GB max file size

# Create upload directory if it doesn't exist
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)
os.makedirs(app.config['BASE_FOLDER'], exist_ok=True)

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

def is_safe_path(base_path, path):
    """Check if path is within base_path (prevent directory traversal)"""
    base_path = os.path.abspath(base_path)
    requested_path = os.path.abspath(os.path.join(base_path, path))
    return requested_path.startswith(base_path)

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

@app.route('/api/version')
@login_required
def get_version():
    """Get current system version"""
    try:
        version_file = os.path.join(os.path.dirname(__file__), 'VERSION')
        if os.path.exists(version_file):
            with open(version_file, 'r') as f:
                version = f.read().strip()
        else:
            version = 'unknown'
        return jsonify({'version': version})
    except Exception as e:
        return jsonify({'version': 'unknown', 'error': str(e)})

@app.route('/api/update/check')
@login_required
def check_update():
    """Check for available updates"""
    try:
        # Get current version
        version_file = os.path.join(os.path.dirname(__file__), 'VERSION')
        current_version = 'unknown'
        if os.path.exists(version_file):
            with open(version_file, 'r') as f:
                current_version = f.read().strip()

        # Check latest version from GitHub
        import urllib.request
        url = 'https://raw.githubusercontent.com/PrizmCaptCore/prizm_nas_os/main/webui/VERSION'
        try:
            with urllib.request.urlopen(url, timeout=10) as response:
                latest_version = response.read().decode('utf-8').strip()
        except:
            latest_version = current_version

        update_available = current_version != latest_version and latest_version != 'unknown'

        return jsonify({
            'current_version': current_version,
            'latest_version': latest_version,
            'update_available': update_available
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/update/start', methods=['POST'])
@login_required
def start_update():
    """Start system update"""
    try:
        update_script = '/usr/local/bin/nas-update.sh'

        if not os.path.exists(update_script):
            return jsonify({'error': 'Update script not found'}), 404

        # Run update script in background with sudo
        # Note: The web UI service should be configured to run this script with proper permissions
        subprocess.Popen(['/usr/bin/sudo', update_script],
                        stdout=subprocess.PIPE,
                        stderr=subprocess.PIPE,
                        start_new_session=True)

        return jsonify({
            'success': True,
            'message': 'Update started. The system will restart when complete.'
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500


# ============================================
# File Management APIs
# ============================================

@app.route('/api/browse')
@login_required
def browse_directory():
    """Browse directory contents"""
    path = request.args.get('path', '')

    # Security check
    if not is_safe_path(app.config['BASE_FOLDER'], path):
        return jsonify({'error': 'Invalid path'}), 403

    full_path = os.path.join(app.config['BASE_FOLDER'], path)

    if not os.path.exists(full_path):
        return jsonify({'error': 'Path does not exist'}), 404

    if not os.path.isdir(full_path):
        return jsonify({'error': 'Not a directory'}), 400

    try:
        items = []
        for item_name in sorted(os.listdir(full_path)):
            item_path = os.path.join(full_path, item_name)
            try:
                stat = os.stat(item_path)
                is_dir = os.path.isdir(item_path)

                items.append({
                    'name': item_name,
                    'type': 'directory' if is_dir else 'file',
                    'size': 0 if is_dir else stat.st_size,
                    'modified': stat.st_mtime,
                    'path': os.path.join(path, item_name)
                })
            except (PermissionError, OSError):
                continue

        return jsonify({
            'current_path': path,
            'items': items
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

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

@app.route('/api/browse/download', methods=['GET'])
@login_required
def download_from_browser():
    """Download a file from file browser"""
    path = request.args.get('path', '')

    if not is_safe_path(app.config['BASE_FOLDER'], path):
        return jsonify({'error': 'Invalid path'}), 403

    full_path = os.path.join(app.config['BASE_FOLDER'], path)

    if not os.path.exists(full_path):
        return jsonify({'error': 'File not found'}), 404

    if os.path.isdir(full_path):
        return jsonify({'error': 'Cannot download directory'}), 400

    try:
        return send_file(full_path, as_attachment=True)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/browse/delete', methods=['DELETE'])
@login_required
def delete_from_browser():
    """Delete a file or directory from file browser"""
    path = request.args.get('path', '')

    if not path:
        return jsonify({'error': 'Path required'}), 400

    if not is_safe_path(app.config['BASE_FOLDER'], path):
        return jsonify({'error': 'Invalid path'}), 403

    full_path = os.path.join(app.config['BASE_FOLDER'], path)

    if not os.path.exists(full_path):
        return jsonify({'error': 'Path not found'}), 404

    try:
        import shutil
        if os.path.isdir(full_path):
            shutil.rmtree(full_path)
        else:
            os.remove(full_path)
        return jsonify({'success': True})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/browse/mkdir', methods=['POST'])
@login_required
def create_directory():
    """Create a new directory"""
    data = request.get_json()
    path = data.get('path', '')
    name = data.get('name', '')

    if not name:
        return jsonify({'error': 'Directory name required'}), 400

    # Sanitize directory name
    name = secure_filename(name)

    if not is_safe_path(app.config['BASE_FOLDER'], path):
        return jsonify({'error': 'Invalid path'}), 403

    parent_path = os.path.join(app.config['BASE_FOLDER'], path)
    new_dir = os.path.join(parent_path, name)

    if os.path.exists(new_dir):
        return jsonify({'error': 'Directory already exists'}), 409

    try:
        os.makedirs(new_dir)
        return jsonify({'success': True, 'path': os.path.join(path, name)})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/browse/upload', methods=['POST'])
@login_required
def upload_to_browser():
    """Upload a file to specific directory in file browser"""
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400

    file = request.files['file']
    path = request.form.get('path', '')

    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400

    if not is_safe_path(app.config['BASE_FOLDER'], path):
        return jsonify({'error': 'Invalid path'}), 403

    target_dir = os.path.join(app.config['BASE_FOLDER'], path)

    if not os.path.exists(target_dir):
        return jsonify({'error': 'Directory does not exist'}), 404

    if not os.path.isdir(target_dir):
        return jsonify({'error': 'Not a directory'}), 400

    try:
        filename = secure_filename(file.filename)
        filepath = os.path.join(target_dir, filename)

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

if __name__ == '__main__':
    # Run on all interfaces, port 80
    app.run(host='0.0.0.0', port=80, debug=False)
