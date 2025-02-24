#!/bin/zsh

# This script downloads and installs Hugo Extended v0.132.2 for macOS.
# It downloads the tarball from GitHub, extracts the hugo binary,
# moves it to ~/.local/bin, and adds ~/.local/bin to the PATH in ~/.zshrc if needed.

# Variables
HUGO_VERSION="0.132.2"
HUGO_FILENAME="hugo_extended_${HUGO_VERSION}_darwin-universal.tar.gz"
DOWNLOAD_URL="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_FILENAME}"
INSTALL_DIR="$HOME/.local/bin"
TMP_DIR=$(mktemp -d)

# Create the installation directory if it doesn't exist.
mkdir -p "$INSTALL_DIR"

echo "Downloading Hugo Extended v${HUGO_VERSION}..."
curl -L -o "$TMP_DIR/$HUGO_FILENAME" "$DOWNLOAD_URL"
if [[ $? -ne 0 ]]; then
  echo "Error: Failed to download Hugo."
  rm -rf "$TMP_DIR"
  exit 1
fi

echo "Extracting Hugo..."
tar -xzf "$TMP_DIR/$HUGO_FILENAME" -C "$TMP_DIR"
if [[ $? -ne 0 ]]; then
  echo "Error: Failed to extract Hugo."
  rm -rf "$TMP_DIR"
  exit 1
fi

# Locate the Hugo binary. The tarball structure might be either:
#   1. Containing the binary directly in the current directory, or
#   2. Wrapping it in a folder.
if [[ -f "$TMP_DIR/hugo" ]]; then
  BINARY_PATH="$TMP_DIR/hugo"
elif [[ -f "$TMP_DIR/hugo/hugo" ]]; then
  BINARY_PATH="$TMP_DIR/hugo/hugo"
else
  echo "Error: Hugo binary not found in the extracted files."
  rm -rf "$TMP_DIR"
  exit 1
fi

echo "Moving Hugo binary to $INSTALL_DIR..."
mv "$BINARY_PATH" "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/hugo"

echo "Cleaning up temporary files..."
rm -rf "$TMP_DIR"

# Ensure that ~/.local/bin appears in the PATH permanently.
ZSHRC_FILE="$HOME/.zshrc"
PATH_EXPORT='export PATH="$HOME/.local/bin:$PATH"'
if ! grep -Fq "$PATH_EXPORT" "$ZSHRC_FILE"; then
  echo "\n# Add Hugo binary directory to PATH" >> "$ZSHRC_FILE"
  echo "$PATH_EXPORT" >> "$ZSHRC_FILE"
  echo "Updated PATH in $ZSHRC_FILE. Please restart your terminal or run 'source ~/.zshrc' to apply the changes."
  source ~/.zshrc
else
  echo "$HOME/.local/bin is already in your PATH in $ZSHRC_FILE."
fi

# Verify installation.
echo "Installation complete. Hugo version:"
"$INSTALL_DIR/hugo" version
