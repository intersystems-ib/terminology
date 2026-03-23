Class Terminology.Snomed.RefsetMember Extends %Persistent
{

Property ReleaseId As %String(MAXLEN = 64) [ Required ];

Property RefsetId As %BigInt [ Required ];

Property MemberId As %String(MAXLEN = 64) [ Required ];

Property ReferencedId As %BigInt [ Required ];

Property Active As %Integer [ Required ];

Property EffectiveTime As %Date;

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
