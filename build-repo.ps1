# ================================
# build-repo.ps1 - Script PRO
# Empaqueta el addon y sube a GitHub
# ================================

# Configuración
$addonFolder   = "plugin.video.viiiiptv"
$addonsXml     = "addons.xml"
$addonsXmlMd5  = "addons.xml.md5"

# Leer addon.xml
$addonXmlPath = Join-Path $addonFolder "addon.xml"
$addonXmlContent = Get-Content $addonXmlPath -Raw

# Extraer versión con regex
if ($addonXmlContent -match 'version="([0-9\.]+)"') {
    $version = $matches[1]
} else {
    Write-Host "ERROR: No se pudo leer la versión en addon.xml"
    exit
}

# Nombre del ZIP
$addonZip = "$addonFolder-$version.zip"
Write-Host "Empaquetando addon v$version en $addonZip ..."

# Eliminar ZIP previo
if (Test-Path $addonZip) {
    Remove-Item $addonZip
}

# Crear ZIP
Compress-Archive -Path $addonFolder -DestinationPath $addonZip -Force
Write-Host "ZIP creado: $addonZip"

# Crear/actualizar addons.xml
Write-Host "Actualizando addons.xml..."
@("<addons>") + (Get-Content $addonXmlPath) + "</addons>" | Set-Content $addonsXml -Encoding UTF8
Write-Host "addons.xml actualizado."

# Generar MD5
Write-Host "Generando addons.xml.md5..."
(Get-FileHash $addonsXml -Algorithm MD5).Hash | Out-File -Encoding ascii $addonsXmlMd5
Write-Host "addons.xml.md5 generado."

# ================================
# Subir cambios a GitHub
# ================================
Write-Host "Subiendo cambios a GitHub..."

# Asegurar que git está disponible
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Git no está instalado o no está en el PATH"
    exit
}

# Añadir archivos al commit
git add .

# Crear mensaje automático con la versión
$commitMessage = "Repo actualizado - versión $version"
git commit -m $commitMessage

# Hacer push (cambia 'main' a 'master'
