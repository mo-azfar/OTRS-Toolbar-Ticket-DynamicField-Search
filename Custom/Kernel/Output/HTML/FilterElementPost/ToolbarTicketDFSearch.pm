# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
package Kernel::Output::HTML::FilterElementPost::ToolbarTicketDFSearch;

use strict;
use warnings;

our @ObjectDependencies = qw(
    Kernel::Config
    Kernel::Output::HTML::Layout
);


sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    $Self->{UserID} = $Param{UserID};

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # get template name
    my $Templatename = $Param{TemplateFile} || '';
    return 1 if !$Templatename;
    return 1 if !$Param{Templates}->{$Templatename};

    return 1 if ${ $Param{Data} } !~ m{<a [^>]+ id="LogoutButton"};

    my $LayoutObject   = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject   = $Kernel::OM->Get('Kernel::Config');
	my $DynamicFieldObject = $Kernel::OM->Get('Kernel::System::DynamicField');
	
	#verify ticket df name
	my $DynamicField = $DynamicFieldObject->DynamicFieldGet(
		Name => $ConfigObject->Get('ToolbarTicketDFSearch::TicketDynamicFieldName'),
	);
		
	if ( $DynamicField->{ID} )
	{
		#check df field type and assign proper html input
		my $InputType;
		if ($DynamicField->{'FieldType'} eq 'Text')
		{
			$InputType=qq~
			<input type='text' size='25' name='Search_DynamicField_$DynamicField->{Name}' id='Search_DynamicField_$DynamicField->{Name}' title='$DynamicField->{Label}'/>"
			~;
		}
		elsif ($DynamicField->{'FieldType'} eq 'Dropdown')
		{
			
			my $BackendObject = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
			#get possible values from df type dropdown
			my $PossibleValues = $BackendObject->PossibleValuesGet(
				DynamicFieldConfig => $DynamicField, 
			);
				
			#build html selection dropdown field
			my $DFField = $LayoutObject->BuildSelection(
				Data            => $PossibleValues,        # use $HashRef, $ArrayRef or $ArrayHashRef (see below)
				Name            => "Search_DynamicField_$DynamicField->{Name}",        # name of element
				ID              => "Search_DynamicField_$DynamicField->{Name}",         
				Title			=> "$DynamicField->{Label}",
				Class           => "Modernize",
				Multiple        => 1,                # (optional) default 0 (0|1)
				Size            => 1,                # (optional) default 1 element size
				TreeView       => 0,                 # (optional) default 0 (0|1)
			);
			
			$InputType=qq~
			$DFField
			~;
		}
		else
		{
			return 1;
		}
		
		my $Baselink    = $LayoutObject->{Baselink};
	
		my $Form = qq~
			<li class="Extended" style="margin-left: 10px">
				<form action="$Baselink" method="post" name="SearchTicketDF">
					<input type="hidden" name="Action" value="AgentTicketSearch"/>
					<input type="hidden" name="Subaction" value="Search"/>
					<input type="hidden" name="ShownAttributes" value="LabelSearch_DynamicField_$DynamicField->{Label}"/>
					$InputType
					<button onclick="$('#SearchTicketDF').attr('target','_blank');">
					<span class="fa fa-search"></span>
					</button>
				</form>
			</li>
		~;
	
		my $Position = $ConfigObject->Get('ToolbarTicketDFSearch::Position') // -3;
		if ( $Position < 0 ) {
			$Position++;
			$Position *= -1;
	
			# place the widget in the output
			${ $Param{Data} } =~ s{(
				<ul \s* id="ToolBar"> .*?
			) (
				(?: (?: <li> .*? </li> \s* ){$Position} )?
				</ul>
			)}{$1 $Form $2 }xsm;
		}
		else {
	
			# place the widget in the output
			${ $Param{Data} } =~ s{
				<ul \s* id="ToolBar"> \s+
					(?: <li (?:[^>]+)?> .*? </li> \s* ){$Position} \K
			}{$Form}xsm;
		}
	
		return 1;
	
	}
			
	
}

1;
