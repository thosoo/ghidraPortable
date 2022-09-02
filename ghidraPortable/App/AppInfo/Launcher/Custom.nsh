;${SegmentFile}

;${SegmentPre}
;    ${If} $Bits = 64
;        ${SetEnvironmentVariablesPath} PATH "%PATH;%PAL:PortableAppsDir\CommonFiles\OpenJDK64\bin"
;    ${Else}
;        ${SetEnvironmentVariablesPath} PATH "%PATH;%PAL:PortableAppsDir\CommonFiles\OpenJDK\bin"
;    ${EndIf}
;!macroend
