Class Terminology.Production.Msg.ICDGetCodeResponse Extends Ens.Response
{

Property Payload As Terminology.ICD.DTO.CodeResult;

Storage Default
{
<Data name="ICDGetCodeResponseDefaultData">
<Subscript>"ICDGetCodeResponse"</Subscript>
<Value name="1">
<Value>Payload</Value>
</Value>
</Data>
<DefaultData>ICDGetCodeResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
