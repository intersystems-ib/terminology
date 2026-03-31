/// Shared serial DTO base for neutral terminology service results.
Class Terminology.Core.DTO.Base Extends (%SerialObject, %JSON.Adaptor, %XML.Adaptor) [ Abstract ]
{

Parameter %JSONNULL = 0;

Storage Default
{
<StreamLocation>^Terminology.Core.DTO.BaseS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
