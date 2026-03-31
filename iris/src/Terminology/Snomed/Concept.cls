/// Stores one SNOMED CT concept row for a specific release.
Class Terminology.Snomed.Concept Extends %Persistent
{

/// Internal release identifier used to partition imported SNOMED data.
Property ReleaseId As %String(MAXLEN = 64) [ Required ];

/// Stable SNOMED CT concept identifier from the RF2 concept file.
Property ConceptId As %BigInt [ Required ];

/// Active flag from RF2, typically 1 for active or 0 for inactive.
Property Active As %Integer [ Required ];

/// Module that published the concept in this release.
Property ModuleId As %BigInt;

/// SNOMED definition status concept id, for example primitive or fully defined.
Property DefinitionStatusId As %BigInt;

/// Effective date carried by the source RF2 row.
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
