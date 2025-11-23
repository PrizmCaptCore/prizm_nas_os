#!/usr/bin/env python3
"""
PRIZM NAS Web UI
Simple and fast NAS management interface
"""

from flask import Flask, render_template, jsonify, request
import subprocess
import json
import os

app = Flask(__name__)

def run_command(cmd):
    """Execute shell command and return output"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=5)
        return result.stdout.strip()
    except Exception as e:
        return f"Error: {str(e)}"

@app.route('/')
def index():
    """Main dashboard"""
    return render_template('index.html')

@app.route('/api/system')
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
def get_disks():
    """Get disk information"""
    # Get disk list
    lsblk = run_command('lsblk -J -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE')
    try:
        disks = json.loads(lsblk)
        return jsonify(disks)
    except:
        return jsonify({'error': 'Failed to get disk info'})

@app.route('/api/network')
def get_network():
    """Get network information"""
    ip = run_command('ip -4 addr show | grep inet | grep -v 127.0.0.1')
    return jsonify({'interfaces': ip.split('\n')})

@app.route('/api/services')
def get_services():
    """Get service status"""
    services = ['sshd', 'smbd', 'nfs-server']
    status = {}
    
    for svc in services:
        result = run_command(f'systemctl is-active {svc} 2>/dev/null || echo inactive')
        status[svc] = result
    
    return jsonify(status)

@app.route('/api/storage')
def get_storage():
    """Get storage usage"""
    df = run_command('df -h | grep -E "^/dev"')
    return jsonify({'storage': df.split('\n')})

if __name__ == '__main__':
    # Run on all interfaces, port 80
    app.run(host='0.0.0.0', port=80, debug=False)
