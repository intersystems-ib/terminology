Class Terminology.Loinc.Closure Extends %Persistent
{

Property ReleaseId As %String(MAXLEN = 64) [ Required ];

Property AncestorCode As %String(MAXLEN = 20) [ Required ];

Property DescendantCode As %String(MAXLEN = 20) [ Required ];

Property Depth As %Integer [ Required ];

Index PK On (ReleaseId, AncestorCode, DescendantCode) [ Unique ];

Index IXDesc On (ReleaseId, DescendantCode, AncestorCode);

Storage Default
{
<Data name="ClosureDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ReleaseId</Value>
</Value>
<Value name="3">
<Value>AncestorCode</Value>
</Value>
<Value name="4">
<Value>DescendantCode</Value>
</Value>
<Value name="5">
<Value>Depth</Value>
</Value>
</Data>
<DataLocation>^Terminology.Loinc.ClosureD</DataLocation>
<DefaultData>ClosureDefaultData</DefaultData>
<IdLocation>^Terminology.Loinc.ClosureD</IdLocation>
<IndexLocation>^Terminology.Loinc.ClosureI</IndexLocation>
<StreamLocation>^Terminology.Loinc.ClosureS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
