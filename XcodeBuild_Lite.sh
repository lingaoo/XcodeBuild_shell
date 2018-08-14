
#!/bin/sh
echo "*注意脚本文件与.xcodeproj、.xcworkspace项目同目录 "
echo " "
# 时间
CurrentDate="$(date +%Y%m%d%H%M)"
# 项目名
PROJECTNAME="ProjectName"
# app名
APP_NAME="ProjectName"
# 版本号
VERSION="0.0.1"
# build号
Build="1"
# 签名证书
CODE_SIGN_IDENTITY="iPhone Distribution: XXXXXXXX"
# provision profile
PROVISIONING_PROFILE="a1687532-903b-XXXXXX-XXXXXXXXXX"

# 不同文件的值
echo -n "Enter any key continua："
read TYPE

MODE="Test"

# 当前目录
FILEPATH=$(cd "$(dirname "$0")"; pwd)
# 输出iap文件名
FileIPAName=$PROJECTNAME"_"$CurrentDate"_v"$VERSION"_"$MODE".ipa"
# 输出xcarchive文件名
ArchiveName=$PROJECTNAME"_"$CurrentDate".xcarchive"
# 输出目录名
DICName=$MODE"_v"$VERSION"_"$CurrentDate
# 全目录
FileIPAPath=$FILEPATH'/'$PROJECTNAME'-IPA/'$DICName'/'$FileIPAName
FileArchivePath=$FILEPATH'/'$PROJECTNAME'-IPA/'$DICName'/'$ArchiveName

cd $FILEPATH

xcodebuild -target $PROJECTNAME clean

XCWORKSPACE=$PROJECTNAME".xcworkspace"

xcodebuild archive -workspace $XCWORKSPACE  -scheme $PROJECTNAME -configuration $MODE -archivePath $FileArchivePath CODE_SIGN_IDENTITY="${CODE_SIGN_IDENTITY}" PROVISIONING_PROFILE="${PROVISIONING_PROFILE}"

echo '准备生成ipa'

XcodeBuildExpentPath=$FILEPATH"/"$PROJECTNAME"-IPA/$DICName"

#生成ipa
xcodebuild -exportArchive -archivePath $FileArchivePath -configuration $MODE -exportPath $XcodeBuildExpentPath  -exportOptionsPlist $FILEPATH"/exportOptionsPlist.plist"

echo $FILEPATH'/'$PROJECTNAME'-IPA/'$DICName"/"$PROJECTNAME".ipa"
echo $FileIPAName

mv $FILEPATH'/'$PROJECTNAME'-IPA/'$DICName"/"$PROJECTNAME".ipa" $FileIPAPath


if test -e $FileIPAPath ;then
echo '构建成功'
exit 0
else
echo "构建失败"
exit 1
fi

