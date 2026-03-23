Class Terminology.Snomed.Relationship Extends %Persistent
{

Property ReleaseId As %String(MAXLEN = 64) [ Required ];

Property RelationshipId As %BigInt [ Required ];

Property Active As %Integer [ Required ];

Property SourceId As %BigInt [ Required ];

Property DestinationId As %BigInt [ Required ];

Property TypeId As %BigInt [ Required ];

Property CharacteristicTypeId As %BigInt;

Property ModifierId As %BigInt;

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
