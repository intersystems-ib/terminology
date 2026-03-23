Class Terminology.Loinc.Code Extends %Persistent
{

Property ReleaseId As %String(MAXLEN = 64) [ Required ];

Property Code As %String(MAXLEN = 20) [ Required ];

Property LongCommonName As %String(MAXLEN = 2000);

Property ShortName As %String(MAXLEN = 255);

Property Status As %String(MAXLEN = 30);

Property Class As %String(MAXLEN = 100);

Property ClassType As %String(MAXLEN = 30);

Property Component As %String(MAXLEN = 255);

Property Property As %String(MAXLEN = 100);

Property TimeAspect As %String(MAXLEN = 100);

Property System As %String(MAXLEN = 100);

Property ScaleType As %String(MAXLEN = 50);

Property MethodType As %String(MAXLEN = 100);

Index PK On (ReleaseId, Code) [ Unique ];

Index IXStatusClass On (ReleaseId, Status, Class);

Index IXSearchShort On (ReleaseId, ShortName);

Index IXSearchLong On (ReleaseId, LongCommonName);

Storage Default
{
<Data name="CodeDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ReleaseId</Value>
</Value>
<Value name="3">
<Value>Code</Value>
</Value>
<Value name="4">
<Value>LongCommonName</Value>
</Value>
<Value name="5">
<Value>ShortName</Value>
</Value>
<Value name="6">
<Value>Status</Value>
</Value>
<Value name="7">
<Value>Class</Value>
</Value>
<Value name="8">
<Value>ClassType</Value>
</Value>
<Value name="9">
<Value>Component</Value>
</Value>
<Value name="10">
<Value>Property</Value>
</Value>
<Value name="11">
<Value>TimeAspect</Value>
</Value>
<Value name="12">
<Value>System</Value>
</Value>
<Value name="13">
<Value>ScaleType</Value>
</Value>
<Value name="14">
<Value>MethodType</Value>
</Value>
</Data>
<DataLocation>^Terminology.Loinc.CodeD</DataLocation>
<DefaultData>CodeDefaultData</DefaultData>
<IdLocation>^Terminology.Loinc.CodeD</IdLocation>
<IndexLocation>^Terminology.Loinc.CodeI</IndexLocation>
<StreamLocation>^Terminology.Loinc.CodeS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
