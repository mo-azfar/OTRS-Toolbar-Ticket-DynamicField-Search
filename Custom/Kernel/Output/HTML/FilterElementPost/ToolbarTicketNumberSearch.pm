# --
# Copyright (C) 2015 - 2016 Perl-Services.de, http://www.perl-services.de/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::FilterElementPost::ToolbarTicketNumberSearch;

use strict;
use warnings;

use List::Util qw(first);

our @ObjectDependencies = qw(
    Kernel::Config
    Kernel::System::Log
    Kernel::System::DB
    Kernel::System::User
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

    return 1 if !first{ $Templatename eq $_ }keys %{ $Param{Templates} };

    return 1 if ${ $Param{Data} } !~ m{<a [^>]+ id="LogoutButton"};

    my $LayoutObject   = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $LanguageObject = $Kernel::OM->Get('Kernel::Language');

    my $Baselink    = $LayoutObject->{Baselink};
    my $Description = $LanguageObject->Translate("TicketNumber") || 'TicketNumber';

    my $Form = qq~
        <li class="Extended SearchFulltext" style="margin-left: 10px">
            <form action="$Baselink" method="post" name="SearchTicketNumber">
                <input type="hidden" name="Action" value="AgentTicketSearch"/>
                <input type="hidden" name="Subaction" value="Search"/>
                <input type="hidden" name="CheckTicketNumberAndRedirect" value="1"/>
                <input type="text" size="25" name="TicketNumber" id="TicketNumber" placeholder="$Description" title="$Description"/>
            </form>
        </li>
    ~;

    # place the widget in the output
    ${ $Param{Data} } =~ s{(
        <ul \s* id="ToolBar"> .*?
    ) (
        (?: (?: <li> .*? </li> \s* ){2} )?
        </ul>
    )}{$1 $Form $2 }xsm;


    return ${ $Param{Data} };
}

1;