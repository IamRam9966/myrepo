#------------------------------------------------------------------------------------------------------------------------------------  
# Name:             create-spo-lists.ps1   
# Description:      This script create SharePoint Online Lists with its
#                   corresponding fields from an XML File that has the List names
#                   and fields
#
# Notes:            The variable $XmlDocument specify the XML File with all the details 
#                   (OppManagementLists.xml)
#
# By:               Piero Marchena
#
# Youtube Channel:  https://www.youtube.com/channel/UCFlKmkMKzPyCoWpAgy-dsPw?sub_confirmation=1
#
# Resources:        https://www.guidgen.com/ (To generate GUIDs for each Field in the XML)
#                   
#                   https://docs.microsoft.com/en-us/powershell/sharepoint/sharepoint-pnp/sharepoint-pnp-cmdlets?view=sharepoint-ps
#-------------------------------------------------------------------------------------------------------------------------------------  

Update-Module SharePointPnPPowerShell*

#Specify Site URL
$siteUrl = "https://demo.sharepoint.com/sites/oppmanagementsite/"

#Connect to SPO Site
Connect-PnPOnline –Url $siteUrl –Credentials (Get-Credential)

#Connect-PnPOnline –Url $siteUrl -UseWebLogin #Use this is your tenant use MFA

#Get the XML File that store the List and Fields
[xml]$XmlDocument = Get-Content -Path .\OppManagementLists.xml

#Go trough each item in the XML File
foreach ($list in $XmlDocument.Lists.List)
{
    try{
        $lname = $list.Name;
        $ltype = $list.Type;

        #Query the List based on the List Name
        $l = Get-PnPList -Identity $lname;
    
        #Validate if the List Exist
        if($l.Title -eq $lname){
            Write-Host $lname "list already exist!" -ForegroundColor Cyan;
        }else{
        
            #If it doesn´t exist, create the SPO List
            Write-host "Creating:" $lname -ForegroundColor Magenta
        
            $newlist = New-PnPList -Title $lname -Template $ltype -OnQuickLaunch
        
            Write-host $lname "list succesfully created!" -ForegroundColor Yellow
        }

        Write-host "Creating Fields..." -ForegroundColor Green

        #Get all the Fields from the SPO List
        $allfields = Get-PnPField -List $lname;

        #Go trough each field in the XML File for the particular List
        foreach ($field in $list.Fields.Field)
        {
       
            $dname = $field.DisplayName;
            $countf = 0;

            #Validate if the field specified in the XML File
            #already exist in the SPO List
            foreach($f in $allfields){
        
                if($f.Title -eq $dname){
                  $countf += 1;
                }
            }


            if($countf -gt 0){
                Write-Host "Field" $dname "already exist!" -ForegroundColor DarkMagenta;
        
            }else{
            #If it doesn´t exist, create and add the new Field to the SPO List

            $type = $field.type;
            $desc = $field.Description;
            $frequired = $field.Required;
            $uniqval = $field.EnforceUniqueValues;
            $findexed = $field.Indexed;
            $fid = $field.ID;
            $fsname = $field.StaticName;
            $fname = $field.Name;

            #Validate the type of field based on that create an XML structure
            #each field type has different properties

            if($type -eq "Text"){
                $fmaxl = $field.MaxLength;
            
                $xmlfield= '<Field Type="' + $type + '" DisplayName="' + $dname + '" Description="' + $desc + '" Required="' + $frequired + '" EnforceUniqueValues="' + $uniqval + '" Indexed="' + $findexed + '" MaxLength="' + $fmaxl + '" ID="' + $fid + '" StaticName="' + $fsname + '" Name="' + $fname  + '"></Field>'

            }elseif($type -eq "DateTime"){
                $xmlfield= '<Field Type="' + $type + '" DisplayName="' + $dname + '" Description="' + $desc + '" Required="' + $frequired + '" EnforceUniqueValues="' + $uniqval + '" Indexed="' + $findexed + '" ID="' + $fid + '" StaticName="' + $fsname + '" Name="' + $fname  + '"></Field>'
    
            }elseif($type -eq "Note"){
                $fnumlines = $field.NumLines;
                $xmlfield= '<Field Type="' + $type + '" DisplayName="' + $dname + '" Description="' + $desc + '" Required="' + $frequired + '" EnforceUniqueValues="' + $uniqval + '" Indexed="' + $findexed + '" NumLines="' + $fnumlines +  '" ID="' + $fid + '" StaticName="' + $fsname + '" Name="' + $fname  + '"></Field>'
        
            }elseif($type -eq "Choice"){
                $fformat = $field.Format;
                $choices = "";

                foreach ($fchoice in $field.CHOICES.CHOICE){
                    $choices += "<CHOICE>" + $fchoice + "</CHOICE>";
                }
        
                $xmlfield= '<Field Type="' + $type + '" DisplayName="' + $dname + '" Description="' + $desc + '" Required="' + $frequired + '" EnforceUniqueValues="' + $uniqval + '" Indexed="' + $findexed + '" Format="' + $fformat + '" ID="' + $fid + '" StaticName="' + $fsname + '" Name="' + $fname  + '"><Default>"' + $field.Default + '"</Default><CHOICES>' + $choices + '</CHOICES></Field>'
    
            }elseif($type -eq "Number"){
                $fmin = $field.Min;
                $fmax = $field.Max;
                $fdec = $field.Decimals;
        
                $xmlfield= '<Field Type="' + $type + '" DisplayName="' + $dname + '" Description="' + $desc + '" Required="' + $frequired + '" EnforceUniqueValues="' + $uniqval + '" Indexed="' + $findexed + '" Min="' + $fmin  + '" Max="' + $fmax + '" Decimals="' + $fdec  + '" ID="' + $fid + '" StaticName="' + $fsname + '" Name="' + $fname  + '"></Field>'
    
            }elseif($type -eq "Boolean"){
                $fdefault = $field.Default;
        
                $xmlfield= '<Field Type="' + $type + '" DisplayName="' + $dname + '" Description="' + $desc + '" Required="' + $frequired + '" EnforceUniqueValues="' + $uniqval + '" Indexed="' + $findexed + '" ID="' + $fid + '" StaticName="' + $fsname + '" Name="' + $fname  + '"><Default>'+ $fdefault + '</Default></Field>'
    
            }elseif($type -eq "URL"){
                $fformat = $field.Format;
        
                $xmlfield= '<Field Type="' + $type + '" DisplayName="' + $dname + '" Description="' + $desc + '" Required="' + $frequired + '" EnforceUniqueValues="' + $uniqval + '" Indexed="' + $findexed + '" Format="' + $fformat + '" ID="' + $fid + '" StaticName="' + $fsname + '" Name="' + $fname  + '"></Field>'
        
            }elseif($type -eq "User"){
                $flist = $field.List;
                $fshowfield = $field.ShowField;
                $fuselmode = $field.UserSelectionMode;
                $fuselscope = $field.UserSelectionScope;
        
                $xmlfield= '<Field Type="' + $type + '" DisplayName="' + $dname + '" Description="' + $desc + '" Required="' + $frequired + '" EnforceUniqueValues="' + $uniqval + '" Indexed="' + $findexed + '" List="' + $flist + '" ShowField="' + $fshowfield + '" UserSelectionMode="' + $fuselmode + '" UserSelectionScope="' + $fuselscope + '" ID="' + $fid + '" StaticName="' + $fsname + '" Name="' + $fname  + '"></Field>'
            
            }elseif($type -eq "MultiChoice"){
            
                $mchoices = "";

                foreach ($fchoice in $field.CHOICES.CHOICE){
                    $mchoices += "<CHOICE>" + $fchoice + "</CHOICE>";
                }
        
                $xmlfield= '<Field Type="' + $type + '" DisplayName="' + $dname + '" Description="' + $desc + '" Required="' + $frequired + '" EnforceUniqueValues="' + $uniqval + '" Indexed="' + $findexed + '" ID="' + $fid + '" StaticName="' + $fsname + '" Name="' + $fname  + '"><Default>"' + $field.Default + '"</Default><CHOICES>' + $mchoices + '</CHOICES></Field>'
    
            }elseif($type -eq "Calculated"){

                $fresultype = $field.ResultType;
                $fformula = $field.Formula;
                      
                $xmlfield= '<Field Type="' + $type + '" DisplayName="' + $dname + '" Description="' + $desc + '" Required="' + $frequired + '" EnforceUniqueValues="' + $uniqval + '" Indexed="' + $findexed + '" ResultType="' + $fresultype + '" ID="' + $fid + '" StaticName="' + $fsname + '" Name="' + $fname  + '"><FieldRefs><FieldRef Name="Title" /></FieldRefs><Formula>'+ $fformula + '</Formula></Field>'
        
            }elseif($type -eq "Currency"){

                $fdecimals = $field.Decimals;
            
                $xmlfield= '<Field Type="' + $type + '" DisplayName="' + $dname + '" Description="' + $desc + '" Required="' + $frequired + '" EnforceUniqueValues="' + $uniqval + '" Indexed="' + $findexed + '" Decimals="' + $fdecimals + '" ID="' + $fid + '" StaticName="' + $fsname + '" Name="' + $fname  + '"></Field>'
            
            }
            
            #Create the Field and Add to the SPO List

            Write-Host "-------------------------------------------------------------" -ForegroundColor Green

            Add-PnPFieldFromXml -List $lname -FieldXml $xmlfield

            Write-Host "Field" $dname "added" -ForegroundColor Cyan  
           }
    }

    Write-host "LIST" $lname "OK!"  -ForegroundColor DarkCyan

    }catch{

        Write-Host "Something went wrong :) $($Error[0].Exception.Message)" -ForegroundColor Red

    }
}
