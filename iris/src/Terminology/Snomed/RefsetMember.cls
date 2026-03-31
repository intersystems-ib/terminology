/// Stores membership rows for SNOMED reference sets in a specific release.
Class Terminology.Snomed.RefsetMember Extends %Persistent
{

/// Internal release identifier used to partition imported SNOMED data.
Property ReleaseId As %String(MAXLEN = 64) [ Required ];

/// Reference set concept id that owns this member.
Property RefsetId As %BigInt [ Required ];

/// RF2 member identifier for the reference set row.
Property MemberId As %String(MAXLEN = 64) [ Required ];

/// Referenced component id, usually a concept or description depending on the refset type.
Property ReferencedId As %BigInt [ Required ];

/// Active flag from RF2, typically 1 for active or 0 for inactive.
Property Active As %Integer [ Required ];

/// Effective date carried by the source RF2 row.
Property EffectiveTime As %Date;

/// Extra refset-specific fields serialized as text when the importer does not model them explicitly.
Property Extra As %String(MAXLEN = 32000);

Index PK On (ReleaseId, RefsetId, MemberId) [ Unique ];

Index IXByReferenced On (ReleaseId, RefsetId, ReferencedId, Active);

Index IXRefsetActive On (ReleaseId, RefsetId, Active);

Storage Default
{
<Data name="RefsetMemberDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ReleaseId</Value>
</Value>
<Value name="3">
<Value>RefsetId</Value>
</Value>
<Value name="4">
<Value>MemberId</Value>
</Value>
<Value name="5">
<Value>ReferencedId</Value>
</Value>
<Value name="6">
<Value>Active</Value>
</Value>
<Value name="7">
<Value>EffectiveTime</Value>
</Value>
<Value name="8">
<Value>Extra</Value>
</Value>
</Data>
<DataLocation>^Terminology.S6D3E.RefsetMemberD</DataLocation>
<DefaultData>RefsetMemberDefaultData</DefaultData>
<IdLocation>^Terminology.S6D3E.RefsetMemberD</IdLocation>
<IndexLocation>^Terminology.S6D3E.RefsetMemberI</IndexLocation>
<StreamLocation>^Terminology.S6D3E.RefsetMemberS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
