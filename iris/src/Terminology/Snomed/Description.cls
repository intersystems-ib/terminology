/// Stores one SNOMED CT description row linked to a concept in a release.
Class Terminology.Snomed.Description Extends %Persistent
{

/// Internal release identifier used to partition imported SNOMED data.
Property ReleaseId As %String(MAXLEN = 64) [ Required ];

/// Stable SNOMED CT description identifier from RF2.
Property DescriptionId As %BigInt [ Required ];

/// Concept that owns this description.
Property ConceptId As %BigInt [ Required ];

/// Active flag from RF2, typically 1 for active or 0 for inactive.
Property Active As %Integer [ Required ];

/// SNOMED description type concept id, such as FSN, synonym, or text definition.
Property TypeId As %BigInt [ Required ];

/// Language code of the term text, for example "es" or "en".
Property Lang As %String(MAXLEN = 10) [ Required ];

/// Human-readable term text shown to users.
Property Term As %String(MAXLEN = 2000) [ Required ];

/// SNOMED case significance concept id for the term.
Property CaseSignificanceId As %BigInt;

/// Effective date carried by the source RF2 row.
Property EffectiveTime As %Date;

Index PK On (ReleaseId, DescriptionId) [ Unique ];

Index IXConcept On (ReleaseId, ConceptId);

Index IXLangActive On (ReleaseId, Lang, Active);

Index IXPreferredBuild On (ReleaseId, Lang, Active, TypeId, ConceptId, DescriptionId);

Storage Default
{
<Data name="DescriptionDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ReleaseId</Value>
</Value>
<Value name="3">
<Value>DescriptionId</Value>
</Value>
<Value name="4">
<Value>ConceptId</Value>
</Value>
<Value name="5">
<Value>Active</Value>
</Value>
<Value name="6">
<Value>TypeId</Value>
</Value>
<Value name="7">
<Value>Lang</Value>
</Value>
<Value name="8">
<Value>Term</Value>
</Value>
<Value name="9">
<Value>CaseSignificanceId</Value>
</Value>
<Value name="10">
<Value>EffectiveTime</Value>
</Value>
</Data>
<DataLocation>^Terminology.Sn6D3E.DescriptionD</DataLocation>
<DefaultData>DescriptionDefaultData</DefaultData>
<IdLocation>^Terminology.Sn6D3E.DescriptionD</IdLocation>
<IndexLocation>^Terminology.Sn6D3E.DescriptionI</IndexLocation>
<StreamLocation>^Terminology.Sn6D3E.DescriptionS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
