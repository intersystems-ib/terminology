Class Terminology.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="Terminology.Production" LogGeneralTraceEvents="true">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="SnomedFileService" Category="" ClassName="Terminology.Production.BS.SnomedRf2FileService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="FilePath">/iris-shared/in/</Setting>
    <Setting Target="Host" Name="TargetConfigName">SnomedFileProcessing</Setting>
    <Setting Target="Host" Name="EffectiveDate">2026-03-19</Setting>
    <Setting Target="Host" Name="ReleaseId">SNOMED CT version 20260101</Setting>
    <Setting Target="Adapter" Name="FileSpec">*.zip</Setting>
  </Item>
  <Item Name="SnomedFileProcessing" Category="" ClassName="Terminology.Production.BP.SnomedRf2Load" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="TempDirectory">/iris-shared/tmp</Setting>
    <Setting Target="Host" Name="PreferredTermLanguageRefsetId">450828004</Setting>
  </Item>
  <Item Name="SnomedGatewayService" Category="" ClassName="Terminology.Production.BS.SnomedGatewayService" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="SnomedRepositoryOperation" Category="" ClassName="Terminology.Production.BO.SnomedRepositoryOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
  </Item>
  <Item Name="SnomedFileProcessingBase" Category="" ClassName="Terminology.Production.BP.SnomedRf2Load" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Host" Name="TempDirectory">/iris-shared/tmp</Setting>
    <Setting Target="Host" Name="BuildIsaClosure">0</Setting>
    <Setting Target="Host" Name="BuildPreferredTerm">0</Setting>
    <Setting Target="Host" Name="PreferredTermDialect">en</Setting>
    <Setting Target="Host" Name="PreferredTermLang">en</Setting>
    <Setting Target="Host" Name="SnomedFileSuffix"></Setting>
    <Setting Target="Host" Name="ClearBeforeLoad">1</Setting>
  </Item>
  <Item Name="SnomedFileServiceBase" Category="" ClassName="Terminology.Production.BS.SnomedRf2FileService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="FilePath">/iris-shared/baseIn/</Setting>
    <Setting Target="Host" Name="TargetConfigName">SnomedFileProcessingBase</Setting>
    <Setting Target="Host" Name="EffectiveDate">2026-03-19</Setting>
    <Setting Target="Host" Name="ReleaseId">SNOMED CT version 20260101</Setting>
    <Setting Target="Adapter" Name="FileSpec">*.zip</Setting>
  </Item>
</Production>
}

}
