/// Stores one SNOMED CT relationship row used to connect concepts in a release.
Class Terminology.Snomed.Relationship Extends %Persistent
{

/// Internal release identifier used to partition imported SNOMED data.
Property ReleaseId As %String(MAXLEN = 64) [ Required ];

/// Stable SNOMED CT relationship identifier from RF2.
Property RelationshipId As %BigInt [ Required ];

/// Active flag from RF2, typically 1 for active or 0 for inactive.
Property Active As %Integer [ Required ];

/// Source concept of the relationship.
Property SourceId As %BigInt [ Required ];

/// Destination concept targeted by the relationship.
Property DestinationId As %BigInt [ Required ];

/// SNOMED attribute type concept id, including IS-A for hierarchy edges.
Property TypeId As %BigInt [ Required ];

/// Characteristic type concept id, for example inferred or stated.
Property CharacteristicTypeId As %BigInt;

/// Relationship modifier concept id from RF2.
Property ModifierId As %BigInt;

/// Effective date carried by the source RF2 row.
Property EffectiveTime As %Date;

Index PK On (ReleaseId, RelationshipId) [ Unique ];

Index IXSourceType On (ReleaseId, SourceId, TypeId, Active);

Index IXDestType On (ReleaseId, DestinationId, TypeId, Active);

Index IXLoadIsa On (ReleaseId, Active, TypeId, CharacteristicTypeId, SourceId, DestinationId);

Storage Default
{
<Data name="RelationshipDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ReleaseId</Value>
</Value>
<Value name="3">
<Value>RelationshipId</Value>
</Value>
<Value name="4">
<Value>Active</Value>
</Value>
<Value name="5">
<Value>SourceId</Value>
</Value>
<Value name="6">
<Value>DestinationId</Value>
</Value>
<Value name="7">
<Value>TypeId</Value>
</Value>
<Value name="8">
<Value>CharacteristicTypeId</Value>
</Value>
<Value name="9">
<Value>ModifierId</Value>
</Value>
<Value name="10">
<Value>EffectiveTime</Value>
</Value>
</Data>
<DataLocation>^Terminology.S6D3E.RelationshipD</DataLocation>
<DefaultData>RelationshipDefaultData</DefaultData>
<IdLocation>^Terminology.S6D3E.RelationshipD</IdLocation>
<IndexLocation>^Terminology.S6D3E.RelationshipI</IndexLocation>
<StreamLocation>^Terminology.S6D3E.RelationshipS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
