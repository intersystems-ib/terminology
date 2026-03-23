Class Terminology.Snomed.Concept Extends %Persistent
{

Property ReleaseId As %String(MAXLEN = 64) [ Required ];

Property ConceptId As %BigInt [ Required ];

Property Active As %Integer [ Required ];

Property ModuleId As %BigInt;

Property DefinitionStatusId As %BigInt;

Property EffectiveTime As %Date;

Index PK On (ReleaseId, ConceptId) [ Unique ];

Index IXActive On (ReleaseId, Active);

Index IXModule On (ReleaseId, ModuleId);

Index IXPreferredConcept On (ReleaseId, ConceptId, Active);

Storage Default
{
<Data name="ConceptDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ReleaseId</Value>
</Value>
<Value name="3">
<Value>ConceptId</Value>
</Value>
<Value name="4">
<Value>Active</Value>
</Value>
<Value name="5">
<Value>ModuleId</Value>
</Value>
<Value name="6">
<Value>DefinitionStatusId</Value>
</Value>
<Value name="7">
<Value>EffectiveTime</Value>
</Value>
</Data>
<DataLocation>^Terminology.Snomed.ConceptD</DataLocation>
<DefaultData>ConceptDefaultData</DefaultData>
<IdLocation>^Terminology.Snomed.ConceptD</IdLocation>
<IndexLocation>^Terminology.Snomed.ConceptI</IndexLocation>
<StreamLocation>^Terminology.Snomed.ConceptS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
