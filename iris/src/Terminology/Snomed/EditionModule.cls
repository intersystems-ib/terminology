Class Terminology.Snomed.EditionModule Extends %Persistent
{

Property ReleaseId As %String(MAXLEN = 64) [ Required ];

Property ModuleId As %BigInt [ Required ];

Property RoleModule As %String(MAXLEN = 30) [ Required ];

Index PK On (ReleaseId, ModuleId) [ Unique ];

Index IXRole On (ReleaseId, RoleModule);

Storage Default
{
<Data name="EditionModuleDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ReleaseId</Value>
</Value>
<Value name="3">
<Value>ModuleId</Value>
</Value>
<Value name="4">
<Value>RoleModule</Value>
</Value>
</Data>
<DataLocation>^Terminology6D3E.EditionModuleD</DataLocation>
<DefaultData>EditionModuleDefaultData</DefaultData>
<IdLocation>^Terminology6D3E.EditionModuleD</IdLocation>
<IndexLocation>^Terminology6D3E.EditionModuleI</IndexLocation>
<StreamLocation>^Terminology6D3E.EditionModuleS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
