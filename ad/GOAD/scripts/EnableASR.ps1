Add-MpPreference -AttackSurfaceReductionRules_Ids 9e6c4e1f-7d60-472f-ba1a-a39ef669e4b2 -AttackSurfaceReductionRules_Actions enable
Add-MpPreference -AttackSurfaceReductionRules_Ids d1e49aac-8f56-4280-b9ba-993a6d77406c -AttackSurfaceReductionRules_Actions enable 
<#
follow the rules id 9e6c4e1f-7d60-472f-ba1a-a39ef669e4b2 block credential stealing from the Windows local security authority subsystem policy.
follow the rules to block credential stealing from the Windows local security authority subsystem policy with the ID 9e6c4e1f-7d60-472f-ba1a-a39ef669e4b2.
refer to https://learn.microsoft.com/en-au/microsoft-365/security/defender-endpoint/attack-surface-reduction-rules-deployment?view=o365-worldwide

Some tips for ASR:
1. for ASR discovery, we can utilize the "win10-asr-get.ps1" script (https://raw.githubusercontent.com/directorcia/Office365/master/win10-asr-get.ps1) to identify open items. another approach involves dumping the VDM file and parsing it using the "vdm_lua_extract.py" script (https://gist.github.com/HackingLZ/65f289b8b0b9c8c3a675aa26c06dfe09). Once the file has been parsed, we can examine the information using "GetRuleInfo" and explore the hardcoded file paths using "GetPathExclusions".
2. we can utilize exclusion settings by specifying excluded folders, effectively bypassing the rules for those specific folders for bypassing this rules.another approach is injecting the process into an existing exclusion process(maybe OPSEC)
#>
