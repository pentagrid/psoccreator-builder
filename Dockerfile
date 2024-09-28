FROM mcr.microsoft.com/dotnet/framework/runtime:4.8-windowsservercore-ltsc2019

# install choco    
ENV chocolateyUseWindowsCompression false
RUN powershell -Command \
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
RUN powershell -Command \
    iex ( (new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
RUN powershell -Command \
    choco feature disable --name showDownloadProgress


#install dependencies to cypress build tools
RUN choco install --ignore-detected-reboot -y python312 
RUN choco install --ignore-detected-reboot -y git
RUN choco install --ignore-detected-reboot -y vcredist2013
RUN choco install --ignore-detected-reboot -y 7zip

# Add git and 7z to the path
RUN mklink /d c:\pf "c:\Program Files"
RUN mklink /d c:\pfx "c:\Program Files (x86)"
RUN setx PATH "%PATH%;c:\pf\Git\bin;c:\pf\7-Zip"

# Add pseudo-alias for python3 using filesystem link
RUN mklink c:\Python312\python3.exe c:\Python312\python.exe

# disable git ownership checks
RUN git config --global --add safe.directory *

# Copy over the cypress build tools
ADD https://pentagrid.blob.core.windows.net/files/min_cycreator_44_0.7z .
RUN 7z.exe x min_cycreator_44_0.7z -oc:\pfx

# delete toolchain archive
RUN del c:\min_cycreator_44_0.7z

# create a symlink for having our 4.4 install pose as 4.3; both use ARM_GCC_541 so whatever
RUN mklink /d "c:\Program Files (x86)\Cypress\PSoC Creator\4.3" "c:\Program Files (x86)\Cypress\PSoc Creator\4.4"

