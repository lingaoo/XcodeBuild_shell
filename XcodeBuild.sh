
#!/bin/sh
echo "*注意脚本文件与.xcodeproj、.xcworkspace项目同目录 "
echo " "
# 时间
CurrentDate="$(date +%Y%m%d%H%M)"
# 项目名
PROJECTNAME=$(sed '/PROJECT_NAME/!d;s/.*=//'  XCConfig/ConfigCommon.xcconfig)
# app名
APP_NAME=$(sed '/APP_NAME/!d;s/.*=//'  XCConfig/ConfigCommon.xcconfig)
# 版本号
VERSION=$(sed '/APP_VERSION/!d;s/.*=//'  XCConfig/ConfigCommon.xcconfig)
# build号
Build=$(sed '/APP_BUILD/!d;s/.*=//'  XCConfig/ConfigCommon.xcconfig)
# 签名证书
CODE_SIGN_IDENTITY=$(sed '/SIGNING_CERTIFICATE/!d;s/.*=//'  XCConfig/ConfigCommon.xcconfig)
# provision profile
PROVISIONING_PROFILE=$(sed '/MOBILEPROVISION/!d;s/.*=//'  XCConfig/ConfigCommon.xcconfig)

# 不同文件的值
echo -n "Enter $APP_NAME IPA Type( Sit / Product ):"
read TYPE
MODE=$TYPE
if [ $MODE == "Sit" ]
then
# app名
APP_NAME=$(sed '/APP_NAME/!d;s/.*=//'  XCConfig/ConfigSit.xcconfig)
fi
if [ $TYPE == "1" ]
then
# app名
APP_NAME=$(sed '/APP_NAME/!d;s/.*=//'  XCConfig/ConfigProductxcconfig)
fi

# 当前目录
FILEPATH=$(cd "$(dirname "$0")"; pwd)
# 输出iap文件名
FileIPAName=$PROFILENAME"_"$CurrentDate"_"$VERSION"_"$MODE".ipa"
# 输出xcarchive文件名
ArchiveName=$PROFILENAME"_"$CurrentDate".xcarchive"
# 输出目录名
DICName=$MODE"_v"$VERSION"_"$CurrentDate
# 全目录
FileIPAPath=$FILEPATH'/'$PROJECTNAME'-API/'$DICName'/'$FileIPAName
FileArchivePath=$FILEPATH'/'$PROJECTNAME'-API/'$DICName'/'$ArchiveName




cd $FILEPATH

xcodebuild -target $PROJECTNAME clean

XCWORKSPACE=$PROJECTNAME".xcworkspace"

xcodebuild archive -workspace "${XCWORKSPACE}"  -scheme $PROJECTNAME -configuration $MODE -archivePath "${FileArchivePath}" CODE_SIGN_IDENTITY="${CODE_SIGN_IDENTITY}" PROVISIONING_PROFILE="${PROVISIONING_PROFILE}"

echo '准备生成ipa'

#生成ipa
xcodebuild -exportArchive -archivePath "${FileArchivePath}" -configuration $MODE -exportPath "${FILEPATH}/${PROJECTNAME}-IPA/${DICName}" -exportOptionsPlist "${FILEPATH}/exportOptionsPlist.plist"

mv $FILEPATH'/'$PROJECTNAME'-API/'$DICName"/"$PROJECTNAME".ipa" $FileIPAName

if test -e $FileIPAPath ;then
# 构建成功
# build号加1
APP_BUILD=$(sed '/APP_BUILD/!d;s/.*=//' /XCConfig/ConfigCommon.xcconfig) #取值
OLD_APP_BUILD="${APP_BUILD// /}" #去空隔
OLD_APP_BUILD='APP_BUILD='$OLD_APP_BUILD  #合并字符串
NEW_APP_BUILD='APP_BUILD='`expr $APP_BUILD + 1`;
TRANATION="s/"$OLD_APP_BUILD'/'$NEW_APP_BUILD"/g"
# sed命令变量时需要去掉空隔
sed  -i '' 's/APP_BUILD = /APP_BUILD=/g' XCConfig/ConfigCommon.xcconfig
sed  -i '' $TRANATION XCConfig/ConfigCommon.xcconfig
sed  -i '' 's/APP_BUILD=/APP_BUILD = /g' XCConfig/ConfigCommon.xcconfig
else
echo "构建失败"
fi

# 关于 exportOptionsPlist.plist
# Xcode ->Open As ->source code 查看下面代码
#
# <?xml version="1.0" encoding="UTF-8"?>
# <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
# <plist version="1.0">
# <dict>
# <key>compileBitcode</key>
# <false/>
# <key>method</key>
# <string>enterprise</string>
# <key>signingCertificate</key>
# <string>iPhone Distribution: XXXXXXXXX</string>
# <key>provisioningProfiles</key>
# <dict>
# <key>com.appID.bundleID</key>
# <string>profile_name</string>
# </dict>
# <key>signingStyle</key>
# <string>manual</string>
# </dict>
# </plist>
#
#
