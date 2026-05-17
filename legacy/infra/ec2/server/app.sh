#!/bin/bash
sudo apt-get update -y
sudo apt-get install -y python3 python3-pip python3-venv nginx

# Create app directory
sudo mkdir -p /var/www/sentiment-analyzer
cd /var/www/sentiment-analyzer

# Create virtual environment
sudo python3 -m venv venv
sudo chown -R ubuntu:ubuntu /var/www/sentiment-analyzer

# Activate and install packages
sudo -u ubuntu bash << 'EOF'
source /var/www/sentiment-analyzer/venv/bin/activate
pip install flask textblob gunicorn
python -m textblob.download_corpora
EOF

# Create Flask app
cat << 'PYTHON' | sudo tee /var/www/sentiment-analyzer/app.py
from flask import Flask, render_template, request, jsonify
from textblob import TextBlob
import json

app = Flask(__name__)

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/analyze', methods=['POST'])
def analyze():
    data = request.get_json()
    text = data.get('text', '')
    
    if not text:
        return jsonify({'error': 'No text provided'}), 400
    
    # Perform sentiment analysis
    blob = TextBlob(text)
    sentiment = blob.sentiment
    
    # Determine sentiment category
    polarity = sentiment.polarity
    if polarity > 0.1:
        category = 'Positive 😊'
        color = '#10b981'
    elif polarity < -0.1:
        category = 'Negative 😞'
        color = '#ef4444'
    else:
        category = 'Neutral 😐'
        color = '#6b7280'
    
    return jsonify({
        'polarity': round(polarity, 4),
        'subjectivity': round(sentiment.subjectivity, 4),
        'category': category,
        'color': color
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
PYTHON

# Create templates directory
sudo mkdir -p /var/www/sentiment-analyzer/templates

# Create HTML template
cat << 'HTML' | sudo tee /var/www/sentiment-analyzer/templates/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI Sentiment Analyzer - AWS EC2</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #1e3c72 0%, #2a5298 50%, #7e22ce 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        .container {
            background: rgba(255, 255, 255, 0.95);
            padding: 40px;
            border-radius: 24px;
            box-shadow: 0 25px 70px rgba(0,0,0,0.3);
            max-width: 800px;
            width: 100%;
            backdrop-filter: blur(10px);
        }
        h1 {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 10px;
            font-size: 2.5em;
            text-align: center;
            font-weight: 800;
        }
        .subtitle {
            text-align: center;
            color: #666;
            margin-bottom: 30px;
            font-size: 1.1em;
        }
        .badge {
            display: inline-block;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 6px 16px;
            border-radius: 20px;
            font-size: 0.85em;
            margin: 5px;
            font-weight: 600;
        }
        textarea {
            width: 100%;
            min-height: 150px;
            padding: 20px;
            border: 2px solid #e5e7eb;
            border-radius: 12px;
            font-size: 1em;
            font-family: inherit;
            resize: vertical;
            transition: border-color 0.3s;
            margin-bottom: 20px;
        }
        textarea:focus {
            outline: none;
            border-color: #667eea;
        }
        button {
            width: 100%;
            padding: 16px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 1.1em;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        button:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(102, 126, 234, 0.4);
        }
        button:active {
            transform: translateY(0);
        }
        .result {
            margin-top: 30px;
            padding: 25px;
            border-radius: 16px;
            display: none;
            animation: slideIn 0.4s ease-out;
        }
        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        .result h3 {
            font-size: 1.8em;
            margin-bottom: 15px;
        }
        .metrics {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
            margin-top: 20px;
        }
        .metric {
            background: rgba(255, 255, 255, 0.7);
            padding: 15px;
            border-radius: 12px;
            text-align: center;
        }
        .metric-label {
            color: #666;
            font-size: 0.9em;
            margin-bottom: 5px;
        }
        .metric-value {
            font-size: 1.8em;
            font-weight: 700;
        }
        .info-box {
            background: #f8fafc;
            padding: 20px;
            border-radius: 12px;
            margin-top: 30px;
            border-left: 4px solid #667eea;
        }
        .info-box h4 {
            color: #667eea;
            margin-bottom: 10px;
            font-size: 1.1em;
        }
        .info-box ul {
            margin-left: 20px;
            color: #555;
        }
        .info-box li {
            margin: 8px 0;
            line-height: 1.5;
        }
        .loading {
            display: none;
            text-align: center;
            color: #667eea;
            margin-top: 20px;
            font-weight: 600;
        }
        .footer {
            text-align: center;
            margin-top: 30px;
            color: #888;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🧠 AI Sentiment Analyzer</h1>
        <p class="subtitle">
            <span class="badge">NLP Powered</span>
            <span class="badge">Real-time Analysis</span>
            <span class="badge">AWS EC2</span>
        </p>
        
        <textarea id="textInput" placeholder="Enter any text to analyze its sentiment... 

Try examples like:
• I absolutely love this product! It's amazing!
• This is the worst experience I've ever had.
• The weather is okay today."></textarea>
        
        <button onclick="analyzeSentiment()">🚀 Analyze Sentiment</button>
        
        <div class="loading" id="loading">⏳ Analyzing text using NLP...</div>
        
        <div class="result" id="result">
            <h3 id="sentiment"></h3>
            <div class="metrics">
                <div class="metric">
                    <div class="metric-label">Polarity Score</div>
                    <div class="metric-value" id="polarity">0</div>
                </div>
                <div class="metric">
                    <div class="metric-label">Subjectivity</div>
                    <div class="metric-value" id="subjectivity">0</div>
                </div>
            </div>
        </div>

        <div class="info-box">
            <h4>📊 How It Works</h4>
            <ul>
                <li><strong>Polarity:</strong> Ranges from -1 (negative) to +1 (positive)</li>
                <li><strong>Subjectivity:</strong> 0 = objective facts, 1 = subjective opinions</li>
                <li><strong>Technology:</strong> TextBlob NLP library with ML-based sentiment analysis</li>
                <li><strong>Deployment:</strong> Python Flask app on AWS EC2 via Terraform</li>
            </ul>
        </div>

        <div class="footer">
            <p>Powered by <strong>TextBlob NLP</strong> | Deployed on <strong>AWS EC2</strong> | Provisioned with <strong>Terraform</strong></p>
        </div>
    </div>

    <script>
        async function analyzeSentiment() {
            const text = document.getElementById('textInput').value;
            if (!text.trim()) {
                alert('Please enter some text to analyze');
                return;
            }

            document.getElementById('loading').style.display = 'block';
            document.getElementById('result').style.display = 'none';

            try {
                const response = await fetch('/analyze', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({ text: text })
                });

                const data = await response.json();

                document.getElementById('sentiment').textContent = data.category;
                document.getElementById('sentiment').style.color = data.color;
                document.getElementById('polarity').textContent = data.polarity;
                document.getElementById('subjectivity').textContent = data.subjectivity;
                
                const resultDiv = document.getElementById('result');
                resultDiv.style.display = 'block';
                resultDiv.style.background = `linear-gradient(135deg, ${data.color}22 0%, ${data.color}11 100%)`;
                resultDiv.style.border = `2px solid ${data.color}44`;
                
                document.getElementById('loading').style.display = 'none';
            } catch (error) {
                console.error('Error:', error);
                alert('Error analyzing sentiment. Please try again.');
                document.getElementById('loading').style.display = 'none';
            }
        }

        // Allow Enter key to submit
        document.getElementById('textInput').addEventListener('keypress', function(e) {
            if (e.key === 'Enter' && e.ctrlKey) {
                analyzeSentiment();
            }
        });
    </script>
</body>
</html>
HTML

# Create systemd service
cat << 'SERVICE' | sudo tee /etc/systemd/system/sentiment-analyzer.service
[Unit]
Description=Sentiment Analyzer Flask App
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/var/www/sentiment-analyzer
Environment="PATH=/var/www/sentiment-analyzer/venv/bin"
ExecStart=/var/www/sentiment-analyzer/venv/bin/gunicorn --workers 3 --bind 0.0.0.0:5000 app:app

[Install]
WantedBy=multi-user.target
SERVICE

# Configure nginx
cat << 'NGINX' | sudo tee /etc/nginx/sites-available/default
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
NGINX

# Start services
sudo systemctl daemon-reload
sudo systemctl enable sentiment-analyzer
sudo systemctl start sentiment-analyzer
sudo systemctl restart nginx
