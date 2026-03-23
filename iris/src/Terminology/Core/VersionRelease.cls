Class Terminology.Core.VersionRelease Extends %Persistent
{

Property ReleaseId As %String(MAXLEN = 64) [ Required ];

Property SystemUri As %String(MAXLEN = 200) [ Required ];

Property VersionUri As %String(MAXLEN = 300);

Property EffectiveDate As %Date;

Property IsActive As %Boolean [ InitialExpression = 0 ];

Property Metadata As %String(MAXLEN = 32000);

Storage Default
{
<Data name="VersionReleaseDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ReleaseId</Value>
</Value>
<Value name="3">
<Value>SystemUri</Value>
</Value>
<Value name="4">
<Value>VersionUri</Value>
</Value>
<Value name="5">
<Value>EffectiveDate</Value>
</Value>
<Value name="6">
<Value>IsActive</Value>
</Value>
<Value name="7">
<Value>Metadata</Value>
</Value>
</Data>
<DataLocation>^TerminologyA191.VersionReleaseD</DataLocation>
<DefaultData>VersionReleaseDefaultData</DefaultData>
<IdLocation>^TerminologyA191.VersionReleaseD</IdLocation>
<IndexLocation>^TerminologyA191.VersionReleaseI</IndexLocation>
<StreamLocation>^TerminologyA191.VersionReleaseS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
