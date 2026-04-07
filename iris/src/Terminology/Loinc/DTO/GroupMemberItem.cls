Class Terminology.Loinc.DTO.GroupMemberItem Extends Terminology.Loinc.DTO.Base
{

Property GroupId As %String;

Property LoincNum As %String;

/// Display type is carried so FHIR expansion can choose one preferred designation per code.
Property DisplayType As %String;

/// RankOrder is carried as a stable tie-breaker when multiple display rows share a code.
Property RankOrder As %Integer;

Property Display As %String(MAXLEN = "");

Storage Default
{
<Data name="GroupMemberItemState">
<Subscript>"GroupMemberItem"</Subscript>
<Value name="1">
<Value>GroupId</Value>
</Value>
<Value name="2">
<Value>LoincNum</Value>
</Value>
<Value name="3">
<Value>DisplayType</Value>
</Value>
<Value name="4">
<Value>RankOrder</Value>
</Value>
<Value name="5">
<Value>Display</Value>
</Value>
</Data>
<State>GroupMemberItemState</State>
<Type>%Storage.Serial</Type>
}

}
