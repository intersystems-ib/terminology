Class Terminology.Core.LicenseNotice Extends %Persistent
{

Property SystemUri As %String(MAXLEN = 200) [ Required ];

Property NoticeText As %String(MAXLEN = 32000) [ Required ];

Property Source As %String(MAXLEN = 2000);

Index PK On SystemUri [ Unique ];

Storage Default
{
<Data name="LicenseNoticeDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>SystemUri</Value>
</Value>
<Value name="3">
<Value>NoticeText</Value>
</Value>
<Value name="4">
<Value>Source</Value>
</Value>
</Data>
<DataLocation>^TerminologyA191.LicenseNoticeD</DataLocation>
<DefaultData>LicenseNoticeDefaultData</DefaultData>
<IdLocation>^TerminologyA191.LicenseNoticeD</IdLocation>
<IndexLocation>^TerminologyA191.LicenseNoticeI</IndexLocation>
<StreamLocation>^TerminologyA191.LicenseNoticeS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
