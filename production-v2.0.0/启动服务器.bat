@echo off
chcp 65001 > nul
echo ========================================
echo   像素风机甲对战游戏 v2.0.0 服务器
echo ========================================
echo.
echo 正在启动HTTP服务器...
echo 请在浏览器中访问: http://localhost:8080
echo 按 Ctrl+C 停止服务器
echo.
miniserve.exe . --port 8080 --index index.html
pause
