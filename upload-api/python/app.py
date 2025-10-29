#!/usr/bin/env python3
"""
MIK Upload API - Python 实现
使用 Flask 框架提供文件上传和预览服务
"""

import os
import time
from pathlib import Path
from flask import Flask, request, jsonify, send_from_directory
from werkzeug.utils import secure_filename

app = Flask(__name__)

# 配置
UPLOAD_PATH = os.getenv('UPLOAD_PATH', './uploads/')
SERVER_PORT = int(os.getenv('PORT', 12345))
MAX_CONTENT_LENGTH = 10 * 1024 * 1024  # 10 MB

app.config['MAX_CONTENT_LENGTH'] = MAX_CONTENT_LENGTH
app.config['UPLOAD_PATH'] = UPLOAD_PATH

# 确保上传目录存在
Path(UPLOAD_PATH).mkdir(parents=True, exist_ok=True)


@app.route('/upload', methods=['POST'])
def upload_file():
    """
    文件上传接口
    
    接收 multipart/form-data 格式的文件上传请求
    参数: fileName - 上传的文件
    返回: JSON 格式的文件访问 URL
    """
    # 检查是否有文件
    if 'fileName' not in request.files:
        return jsonify({'error': '没有文件'}), 400
    
    file = request.files['fileName']
    
    # 检查文件是否为空
    if file.filename == '':
        return jsonify({'error': '文件名为空'}), 400
    
    if file:
        # 获取文件扩展名
        original_filename = secure_filename(file.filename)
        file_ext = Path(original_filename).suffix.lstrip('.')
        
        if not file_ext:
            return jsonify({'error': '无效的文件扩展名'}), 400
        
        # 创建按类型分类的目录
        ext_dir = os.path.join(UPLOAD_PATH, file_ext)
        Path(ext_dir).mkdir(parents=True, exist_ok=True)
        
        # 生成唯一文件名
        timestamp = str(int(time.time() * 1000))
        new_filename = f"{timestamp}{original_filename}"
        file_path = os.path.join(ext_dir, new_filename)
        
        # 保存文件
        try:
            file.save(file_path)
        except Exception as e:
            return jsonify({'error': f'保存文件失败: {str(e)}'}), 500
        
        # 生成访问 URL
        scheme = request.scheme
        host = request.host
        url_path = f"{scheme}://{host}/archive/{file_ext}/{new_filename}"
        
        return jsonify({
            'data': {
                'url': url_path
            }
        })
    
    return jsonify({'error': '上传失败'}), 400


@app.route('/archive/<path:filename>')
def serve_file(filename):
    """
    文件预览接口
    
    提供已上传文件的访问服务
    """
    return send_from_directory(UPLOAD_PATH, filename)


@app.route('/health')
def health():
    """健康检查接口"""
    return jsonify({'status': 'ok'})


if __name__ == '__main__':
    print(f"Server starting on http://localhost:{SERVER_PORT}")
    print(f"Upload path: {UPLOAD_PATH}")
    app.run(host='0.0.0.0', port=SERVER_PORT, debug=False)

