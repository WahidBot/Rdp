FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Install required components
RUN powershell -Command Add-WindowsCapability -Online -Name RDS-RD-Server

# Download and install ngrok
RUN powershell -Command "Invoke-WebRequest https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-windows-amd64.zip -OutFile ngrok.zip; \
    Expand-Archive ngrok.zip; \
    Remove-Item ngrok.zip"

# Expose RDP port
EXPOSE 3389

# Set RDP Environment Variables
ENV REMOTEDESKTOPENV="REMOTEDESKTOPENV=TRUE"
ENV REMOTEDESKTOPAPP="REMOTEDESKTOPAPP=TRUE"
ENV REMOTEDESKTOPDEFAULTAPP="REMOTEDESKTOPDEFAULTAPP=TRUE"

# Set ngrok authtoken (replace with your authtoken)
ENV NGROK_AUTH_TOKEN=2g1IaTMBV47TkAnpwqkbuXU7vzS_63V3zxECN7mZwqmtFd9UL

# Start RDP and ngrok at runtime
ENTRYPOINT ["powershell.exe", "-ExecutionPolicy", "Bypass", "-NoLogo", "-Command"]
CMD Start-Process -FilePath 'C:\Windows\System32\svsshell.exe' -ArgumentList '/logoncommand:powershell.exe /c Enable-RemoteDesktop' ; \
    .\ngrok.exe authtoken $env:NGROK_AUTH_TOKEN ; \
    .\ngrok.exe tcp 3389 ; \
    Server -Window -NoExit -StartRemoteDesktopServices
