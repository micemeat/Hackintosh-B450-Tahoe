#!/bin/bash
# Compile SSDT files to AML on macOS
# Run this on your Mac after installing iasl via: brew install acpica

cd "$(dirname "$0")/EFI/OC/ACPI"

echo "Compiling SSDT-PLUG.dsl..."
iasl SSDT-PLUG.dsl
if [ $? -eq 0 ]; then
    echo "✅ SSDT-PLUG.aml created"
fi

echo "Compiling SSDT-EC-USBX.dsl..."
iasl SSDT-EC-USBX.dsl
if [ $? -eq 0 ]; then
    echo "✅ SSDT-EC-USBX.aml created"
fi

echo ""
echo "Move the .aml files to EFI/OC/ACPI/ folder"
