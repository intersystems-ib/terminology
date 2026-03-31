/// Maps a release to the modules that belong to the loaded SNOMED edition or extension.
Class Terminology.Snomed.EditionModule Extends %Persistent
{

/// Internal release identifier used to partition imported SNOMED data.
Property ReleaseId As %String(MAXLEN = 64) [ Required ];

/// Module concept id present in the edition.
Property ModuleId As %BigInt [ Required ];

/// Local role assigned to the module during import logic.
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
