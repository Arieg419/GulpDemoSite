#!/bin/bash
cp public/browserData/victory.txt public/browserData/send.txt
cp public/browserData/send.txt ~/Desktop/DynamicTimeline/public/browserData/victory.txt
cat public/browserData/victory.txt >> efratBrowser.txt
rm public/browserData/victory.txt
