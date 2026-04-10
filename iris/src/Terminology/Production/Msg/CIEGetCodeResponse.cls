Class Terminology.Production.Msg.CIEGetCodeResponse Extends Ens.Response
{

Property Payload As Terminology.CIE.DTO.CodeResult;

Storage Default
{
<Data name="CIEGetCodeResponseDefaultData">
<Subscript>"CIEGetCodeResponse"</Subscript>
<Value name="1">
<Value>Payload</Value>
</Value>
</Data>
<DefaultData>CIEGetCodeResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
