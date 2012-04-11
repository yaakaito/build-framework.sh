FRAMEWORK_NAME=${PROJECT_NAME}
FRAMEWORK_VERSION=A
FRAMEWORK_VERSION_NUMBER=1.0
FRAMEWORK_BUILD_PATH="${SRCROOT}/build/${CONFIGURATION}-framework"
FRAMEWORK_DIR="${FRAMEWORK_BUILD_PATH}/${FRAMEWORK_NAME}.framework"
FRAMEWORK_PACKAGE_NAME="${FRAMEWORK_NAME}.${FRAMEWORK_VERSION_NUMBER}.zip"

rm -rf "${FRAMEWORK_BUILD_PATH}"

if [ ${CONFIGURATION} = "Debug" ]; then
    xcodebuild -project ${PROJECT_NAME}.xcodeproj -sdk iphonesimulator${SDK_VERSION} -target "yourproject" \
    -configuration ${CONFIGURATION} clean build

    if [ $? -ne 0 ]; then
        echo "build simulator failed"
        exit -1
    fi
fi

xcodebuild -project ${PROJECT_NAME}.xcodeproj -sdk iphoneos${SDK_VERSION} -target "yourproject" \
-configuration ${CONFIGURATION} clean build

if [ $? -ne 0 ]; then
    echo "build device failed"
    exit -1
fi

mkdir -p ${FRAMEWORK_DIR}
mkdir -p ${FRAMEWORK_DIR}/Versions
mkdir -p ${FRAMEWORK_DIR}/Versions/${FRAMEWORK_VERSION}
mkdir -p ${FRAMEWORK_DIR}/Versions/${FRAMEWORK_VERSION}/Resources
mkdir -p ${FRAMEWORK_DIR}/Versions/${FRAMEWORK_VERSION}/Headers

cd ${FRAMEWORK_DIR}
cd Versions

ln -s ./${FRAMEWORK_VERSION} ./Current
cd ..
ln -s ./Versions/Current/Headers ./Headers
ln -s ./Versions/Current/Resources ./Resources
ln -s ./Versions/Current/${FRAMEWORK_NAME} ./${FRAMEWORK_NAME}

if [ ${CONFIGURATION} = "Debug" ]; then
    lipo ${SRCROOT}/build/${CONFIGURATION}-iphoneos/lib${FRAMEWORK_NAME}.a \
    ${SRCROOT}/build/${CONFIGURATION}-iphonesimulator/lib${FRAMEWORK_NAME}.a \
    -create -output "${FRAMEWORK_DIR}/Versions/Current/${FRAMEWORK_NAME}"
else
    lipo ${SRCROOT}/build/${CONFIGURATION}-iphoneos/lib${FRAMEWORK_NAME}.a \
    -create -output "${FRAMEWORK_DIR}/Versions/Current/${FRAMEWORK_NAME}"
fi

cp ${SRCROOT}/yourproject/*.h ${FRAMEWORK_DIR}/Headers/
