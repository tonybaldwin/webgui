package WebGUI::Asset::MatrixListing;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use Tie::IxHash;
use Moose;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset';
define assetName => ['assetName', 'Asset_MatrixListing'];
define tableName => 'MatrixListing';
property screenshots => (
            tab             => "properties",
            fieldType       => "image",
            default         => undef,
            maxAttachments  => 20,
            label           => ["screenshots label", 'Asset_MatrixListing'],
            hoverHelp       => ["screenshots description", 'Asset_MatrixListing'],
         );
property description => (
            tab             => "properties",
            fieldType       => "HTMLArea",
            default         => undef,
            label           => ["description label", 'Asset_MatrixListing'],
            hoverHelp       => ["description description", 'Asset_MatrixListing'],
         );
property version => (
            tab             => "properties",
            fieldType       => "text",
            default         => undef,
            label           => ["version label", 'Asset_MatrixListing'],
            hoverHelp       => ["version description", 'Asset_MatrixListing'],
         );
property score => (
            fieldType       => 'integer',
            default         => 0,
            noFormPost      => 1,
         );
property views => (
            fieldType       => 'integer',
            default         => 0,
            noFormPost      => 1,
         );
property compares => (
            fieldType       => 'integer',
            default         => 0,
            noFormPost      => 1,
         );
property clicks => (
            fieldType       => 'integer',
            default         => 0,
            noFormPost      => 1,
         );
property viewsLastIp => (
            fieldType       => 'text',
            default         => undef,
            noFormPost      => 1,
         );
property comparesLastIp => (
            fieldType       => 'text',
            default         => undef,
            noFormPost      => 1,
         );
property clicksLastIp => (
            fieldType       => 'text',
            default         => undef,
            noFormPost      => 1,
         );
property maintainer => (
            tab             => "properties",
            fieldType       => "user",
            builder         => '_maintainer_default',
            lazy            => 1,
            label           => ["maintainer label", 'Asset_MatrixListing'],
            hoverHelp       => ["maintainer description", 'Asset_MatrixListing'],
         );
sub _maintainer_default {
    return shift->session->user->userId;
}
property manufacturerName => (
            tab             => "properties",
            fieldType       => "text",
            default         => undef,
            label           => ["manufacturerName label", 'Asset_MatrixListing'],
            hoverHelp       => ["manufacturerName description", 'Asset_MatrixListing']
         );
property manufacturerURL => (
            tab             => "properties",
            fieldType       => "url",
            default         => undef,
            label           => ["manufacturerURL label", 'Asset_MatrixListing'],
            hoverHelp       => ["manufacturerURL description", 'Asset_MatrixListing']
         );
property productURL => (
            tab             => "properties",
            fieldType       => "url",
            default         => undef,
            label           => ["productURL label", 'Asset_MatrixListing'],
            hoverHelp       => ["productURL description", 'Asset_MatrixListing']
         );
property lastUpdated => (
            default         => sub { time() },
            noFormPost      => 1,
            fieldType       => 'hidden',
         );

with 'WebGUI::Role::Asset::Comments';


=head1 NAME

Package WebGUI::Asset::MatrixListing

=head1 DESCRIPTION

Describe your New Asset's functionality and features here.

=head1 SYNOPSIS

use WebGUI::Asset::MatrixListing;


=head1 METHODS

These methods are available from this class:

=cut

#----------------------------------------------------------------------------

=head2 canAdd ( )

Override canAdd to ignore its permissions check. Permissions are handled
by the parent Matrix.

=cut

sub canAdd {
    return 1;
}

#----------------------------------------------------------------------------

=head2 canEdit (  )

Returns true if the user can edit this asset. C<userId> is a WebGUI user ID. 

Users can edit this Matrix listing if they are the owner, or if they can edit
the parent Matrix.

=cut

sub canEdit {
    my $self        = shift;

    if ( $self->session->form->process("assetId") eq "new" ) {
        return $self->getParent->canAddMatrixListing();
    }
    else {
        return 1 if $self->session->user->userId eq $self->get("ownerUserId");

        return $self->getParent->canEdit();
    }
}

#-------------------------------------------------------------------

=head2 getAutoCommitWorkflowId

Gets the WebGUI::VersionTag workflow to use to automatically commit MatrixListings. 
By specifying this method, you activate this feature.

=cut

sub getAutoCommitWorkflowId {
    my $self = shift;
    
    if($self->session->form->process("assetId") eq "new"){
        return $self->getParent->get("submissionApprovalWorkflowId");
    }
    return undef;
}

#-------------------------------------------------------------------

=head2 getEditForm ( )

Returns the FormBuilder object that will be used in generating the edit page for this asset.

=cut

sub getEditForm {
    my $self        = shift;
    my $session     = $self->session;
    my $db          = $session->db;
    my $matrixId    = $self->getParent->getId;
    my $i18n        = WebGUI::International->new($session, 'Asset_MatrixListing');
    my $func        = $session->form->process("func");

    my $form = WebGUI::FormBuilder->new($session, action => $self->getParent->getUrl, );

    if ($func eq "add" || ( $func eq "addSave" && $session->form->process("assetId") eq "new")) {
        $form->addField( "hidden", 
            name           => 'assetId',
            value          => 'new',
        );
        $form->addField( "hidden", 
            name           => 'className',
            value          => 'WebGUI::Asset::MatrixListing',
        );
        $form->addField( "hidden", 
            name           =>'func',
            value          =>'addSave',
        );
    }
    else {
        $form->addField( "hidden", 
            name           =>'func',
            value          =>'editSave',
        );
    }
    $form->addField( "text", 
        name           =>'title',
        defaultValue   =>'Untitled',
        label          =>$i18n->get("product name label"),
        hoverHelp      =>$i18n->get('product name description'),
        value          =>$self->title,
    );

    $form->addField( "image", 
        name           =>'screenshots',
        defaultValue   =>undef,
        maxAttachments =>20,
        label          =>$i18n->get("screenshots label"),
        hoverHelp      =>$i18n->get("screenshots description"),,
        value          =>$self->screenshots,
        );
    $form->addField( "HTMLArea", 
        name           =>'description',
        defaultValue   =>undef,
        label          =>$i18n->get("description label"),
        hoverHelp      =>$i18n->get("description description"),
        value          =>$self->description,
        );
    if ($self->getParent->canEdit) {
        $form->addField( "user", 
            name        =>"ownerUserId",
            value       =>$self->ownerUserId,
            label       =>$i18n->get('maintainer label'),
            hoverHelp   =>$i18n->get('maintainer description'),
            );
    }
    else{
        my $userId;
        if ($func eq "add"){
            $userId = $session->user->userId;
        }
        else{
            $userId = $self->get('ownerUserId');
        }
        $form->addField( "hidden", 
            name           =>'ownerUserId',
            value          =>$userId,
        );
    }
    $form->addField( "text", 
        name           =>'version',
        defaultValue   =>undef,
        label          =>$i18n->get("version label"),
        hoverHelp      =>$i18n->get("version description"),
        value          =>$self->version,
        );
    $form->addField( "text", 
        name           =>'manufacturerName',
        defaultValue   =>undef,
        label          =>$i18n->get("manufacturerName label"),
        hoverHelp      =>$i18n->get("manufacturerName description"),
        value          =>$self->manufacturerName,
        );
    $form->addField( "url", 
        name           =>'manufacturerURL',
        defaultValue   =>undef,
        label          =>$i18n->get("manufacturerURL label"),
        hoverHelp      =>$i18n->get("manufacturerURL description"),
        value          =>$self->manufacturerURL,
        );
    $form->addField( "url", 
        name           =>'productURL',
        defaultValue   =>undef,
        label          =>$i18n->get("productURL label"),
        hoverHelp      =>$i18n->get("productURL description"),
        value          =>$self->productURL,
        );

    foreach my $category (keys %{$self->getParent->getCategories}) {
        my $fieldset = $form->addFieldset( name => $category, label => $category );
        my $attributes = $db->read("select * from Matrix_attribute where category = ? and assetId = ?",
            [$category,$matrixId]);
        while (my $attribute = $attributes->hashRef) {
            $attribute->{label}     = $attribute->{name};
            $attribute->{subtext}   = $attribute->{description};
            $attribute->{name}      = 'attribute_'.$attribute->{attributeId}; 
            unless($session->form->process('func') eq 'add'){
                $attribute->{value} = $db->quickScalar("select value from MatrixListing_attribute 
                    where attributeId = ? and matrixId = ? and matrixListingId = ?",
                    [$attribute->{attributeId},$matrixId,$self->getId]);
            }
            if($attribute->{fieldType} eq 'Combo'){
                my %options;
                tie %options, 'Tie::IxHash';
                %options = $db->buildHash("select value, value from MatrixListing_attribute 
                    where attributeId = ? and value != '' order by value",[$attribute->{attributeId}]);
                $attribute->{options}   = \%options;
                $attribute->{extras}    = "style='width:120px'";
            }
            $fieldset->addField( delete $attribute->{fieldType}, %{$attribute});
        }
    }

    my $buttons = $form->addField( "ButtonGroup", name => "saveButtons", rowClass => "saveButtons" );
    $buttons->addButton( "Submit", { name => "send", });
    $buttons->addButton( "Button", {
        name => "cancel", 
        value => $i18n->get('cancel', 'WebGUI'),
        extras => q{onclick="history.go(-1);" class="backwardButton"},
    } );

    return $form;
}

#-------------------------------------------------------------------

=head2 getEditTemplate ( )

Override the base method to get the template from the parent Matrix asset.

=cut

sub getEditTemplate {
    my $self = shift;
    my $var         = $self->get;
    my $matrix      = $self->getParent;
    my $template    = eval { WebGUI::Asset->newById($self->session, $matrix->get('editListingTemplateId')); };
    # TODO: Change to FormBuilder
    $var->{form}    = $self->getEditForm->toHtml;
    $template->setParam(%{ $var });
    $template->style($matrix->getStyleTemplateId);
    return $template;
}

#-------------------------------------------------------------------

=head2 hasRated ( )

Returns whether the user has already rated this listing or not.

=cut

sub hasRated {
    my $self    = shift;
    my $session = $self->session;

    my $hasRated = $self->session->db->quickScalar("select count(*) from MatrixListing_rating where
        ((userId=? and userId<>'1') or (userId='1' and ipAddress=?)) and listingId=?",
        [$session->user->userId,$session->request->env->{"HTTP_X_FORWARDED_FOR"}, $self->getId]);
    return $hasRated;

}

#-------------------------------------------------------------------

=head2 incrementCounter ( counter )

Increments one of the Matrix Listing's counters.

=head3 counter

The name of the counter to increment this should be 'views', 'clicks' or 'compares').

=cut

sub incrementCounter {
    my $self    = shift;
    my $db      = $self->session->db;
    my $counter = shift;
    
    my $currentIp = $self->session->request->env->{"HTTP_X_FORWARDED_FOR"};
    
    unless ($self->get($counter."LastIp") && ($self->get($counter."LastIp") eq $currentIp)) {
        $self->update({ 
            $counter."LastIp"   => $currentIp,
            $counter            => $self->get($counter)+1
        });
    }
    return undef;
}

#-------------------------------------------------------------------

=head2 indexContent ( )

Making private. See WebGUI::Asset::indexContent() for additonal details. 

=cut

around indexContent => sub {
	my $orig = shift;
	my $self = shift;
	my $indexer = $self->$orig(@_);
	$indexer->setIsPublic(0);
    return undef;
};


#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
	my $self = shift;
	$self->next::method();
	my $template = WebGUI::Asset::Template->newById($self->session, $self->getParent->get('detailTemplateId'));
    $template->prepare;
	$self->{_viewTemplate} = $template;
    return undef;
}


#-------------------------------------------------------------------

=head2 processEditForm ( )

Used to process properties from the form posted.  

=cut

sub processEditForm {
	my $self    = shift;
    my $session = $self->session;
    my $score   = 0;

	$self->next::method(@_);

    my $attributes = $session->db->read("select * from Matrix_attribute where assetId = ?",[$self->getParent->getId]);
    while (my $attribute = $attributes->hashRef) {
        my $name = 'attribute_'.$attribute->{attributeId};
        my $value;
        if ($attribute->{fieldType} eq 'MatrixCompare'){
            $value = $session->form->process($name);
            $score = $score + $value;
        }
        else{
            $value = $session->form->process($name,$attribute->{fieldType},$attribute->{defaultValue},$attribute);
        }
        $session->db->write("replace into MatrixListing_attribute (matrixId, matrixListingId, attributeId, value) 
            values (?, ?, ?, ?)",
            [$self->getParent->getId,$self->getId,$attribute->{attributeId},$value]);
    }
    $self->update({score => $score});    

    if ( $self->get('screenshots') ) {
        my $fileObject = WebGUI::Form::File->new($self->session,{ value=>$self->get('screenshots') });
        my $storage = $fileObject->getStorageLocation;
        my @files;
        @files = @{ $storage->getFiles } if (defined $storage);
        foreach my $file (@files) {
            unless ($file =~ m/^thumb-/){
                my ($resizeWidth,$resizeHeight);
                my ($width, $height) = $storage->getSizeInPixels($file);
                my $maxWidth    = $self->getParent->get('maxScreenshotWidth');
                my $maxHeight   = $self->getParent->get('maxScreenshotHeight');
                if ($width > $maxWidth){
                    my $newHeight = $height * ($maxWidth / $width);
                    if ($newHeight > $maxHeight){
                        # Heigth requires more resizing so use maxHeight
                        $storage->resize($file, 0, $maxHeight);
                    }
                    else{
                        $storage->resize($file, $maxWidth);
                    }
                }
                elsif($height > $maxHeight){
                    $storage->resize($file, 0, $maxHeight);
                }
            }
        }
    }

    $self->requestAutoCommit;
    return undef;
}


#-------------------------------------------------------------------

=head2 purge ( )

This method is called when data is purged by the system.
removes collateral data associated with a MatrixListing when the system
purges it's data.  

=cut

override purge => sub {
	my $self    = shift;
    my $db      = $self->session->db;

    $db->write("delete from MatrixListing_attribute     where matrixListingId=?",[$self->getId]);    
    $db->write("delete from MatrixListing_rating        where listingId=?"      ,[$self->getId]);
    $db->write("delete from MatrixListing_ratingSummary where listingId=?"      ,[$self->getId]);

	return super();
};

#-------------------------------------------------------------------

=head2 setRatings ( ratings  )

Sets the ratings for a matrix listing

=head3 ratings

A hashref containing the ratings to set for this listing.

=cut

sub setRatings {
    my $self        = shift;
    my $ratings     = shift;
    my $session     = $self->session;
    my $db          = $session->db;
    my $matrixId    = $self->getParent->getId;
    
    foreach my $category (keys %{$self->getParent->getCategories}) {
        if ($ratings->{$category}) {
            $db->write("insert into MatrixListing_rating 
                (userId, category, rating, timeStamp, listingId, ipAddress, assetId) values (?,?,?,?,?,?,?)",
                [$session->user->userId,$category,$ratings->{$category},time(),$self->getId,
                $session->request->env->{"HTTP_X_FORWARDED_FOR"}, $matrixId]);
        }
        my $sql     = "from MatrixListing_rating where listingId=? and category=?";
        my $sum     = $db->quickScalar("select sum(rating) $sql", [$self->getId,$category]);
        my $count   = $db->quickScalar("select count(*) $sql", [$self->getId,$category]);
        
        my $half    = sprintf('%.0f', $count/2);
        my $mean    = $sum / ($count || 1);
        my $median  = $db->quickScalar("select rating $sql order by rating limit $half,1",[$self->getId,$category]);
        
        $db->write("replace into MatrixListing_ratingSummary 
            (listingId, category, meanValue, medianValue, countValue, assetId) 
            values (?,?,?,?,?,?)",[$self->getId,$category,$mean,$median,$count,$matrixId]);
    }
    return undef;
}

#-------------------------------------------------------------------

=head2 updateScore ( )

Updates the score of a MatrixListing. 

=cut

sub updateScore {
    my $self = shift;
    my $score = $self->session->db->quickScalar("select sum(value) from MatrixListing_attribute 
            left join Matrix_attribute using(attributeId) 
            where matrixListingId = ? and fieldType = 'MatrixCompare'",[$self->getId]);
    $self->update({score => $score});
    return undef;
}

#-------------------------------------------------------------------

=head2 view ( hasRated )

method called by the container www_view method. 

=head3 hasRated

A boolean indicating if the user has rated this listing.

=head3 emailSent 

A boolean indicating if an email to the listing maintainer was sent.

=cut

sub view {
	my $self        = shift;
    my $hasRated    = shift || $self->hasRated;
    my $emailSent   = shift;
    my $session     = $self->session;
    my $db          = $session->db;
    my $i18n        = WebGUI::International->new($self->session, "Asset_MatrixListing");
    my @categories  = keys %{$self->getParent->getCategories};
  
    # Increment views before getting template var hash so that the views tmpl_var has the incremented value. 
    $self->incrementCounter("views");

	my $var = $self->get;
    if ($emailSent){
    	$var->{emailSent}       = 1;
    }

    unless($self->hasBeenCommitted){
        my $workflowInstanceId = $db->quickScalar("select workflowInstanceId from assetVersionTag where tagId =?"
            ,[$self->get('tagId')]);
        $var->{canApprove}          = $self->getParent->canEdit;
        $var->{approveOrDenyUrl}    = $self->getUrl("op=manageRevisionsInTag;workflowInstanceId=".$workflowInstanceId
            .";tagId=".$self->get('tagId'));
    }
    $var->{canEdit}             = $self->canEdit;
    $var->{editUrl}             = $self->getUrl("func=edit");
    $var->{controls}            = $self->getToolbar;
    $var->{comments}            = $self->getFormattedComments();
    $var->{productName}         = $var->{title};
    $var->{lastUpdated_epoch}   = $self->get('lastUpdated');
    $var->{lastUpdated_date}    = $session->datetime->epochToHuman($self->get('lastUpdated'),"%z");

    $var->{manufacturerUrl_click}  = $self->getUrl("func=click;manufacturer=1");
    $var->{productUrl_click}       = $self->getUrl("func=click");

    if($self->get('status') eq 'pending'){
        my $revisionDate                = $self->get('revisionDate');
        $var->{revision}                = $revisionDate;
        $var->{manufacturerUrl_click}   .= ';revision='.$revisionDate;
        $var->{productUrl_click}        .= ';revision='.$revisionDate;
    }

    $self->session->style->setScript($self->session->url->extras('yui/build/utilities/utilities.js'));
    $self->session->style->setScript($self->session->url->extras('yui/build/datasource/datasource-min.js'));
    $self->session->style->setScript($self->session->url->extras('yui/build/datatable/datatable-min.js'));
    $self->session->style->setScript($self->session->url->extras('yui/build/button/button-min.js'));
    $self->session->style->setScript($self->session->url->extras('yui/build/json/json-min.js'));
    $self->session->style->setCss($self->session->url->extras('yui/build/datatable/assets/skins/sam/datatable.css'));

    # Attributes
   
    foreach my $category (@categories) {
        my $attributes;
        my @attribute_loop;
        my $categoryLoopName = $session->url->urlize($category)."_loop";
        $attributes = $db->read("select * from Matrix_attribute as attribute
            left join MatrixListing_attribute as listing using(attributeId)
            where listing.matrixListingId = ? and category =? and attribute.assetId = ?",
            [$self->getId,$category,$self->getParent->getId]);
        while (my $attribute = $attributes->hashRef) {
            $attribute->{label} = $attribute->{name};
            if ($attribute->{fieldType} eq 'MatrixCompare'){
                $attribute->{value} = WebGUI::Form::MatrixCompare->new($session,$attribute)->getValueAsHtml;
            }
            push(@attribute_loop,$attribute);
        }
        $var->{$categoryLoopName} = \@attribute_loop;
        push(@{$var->{category_loop}},{
            categoryLabel   => $category,
            attribute_loop  => \@attribute_loop,
        });
    }

    # Screenshots

    if ($var->{screenshots}) {
        my $file = WebGUI::Form::File->new($session,{ value=>$var->{screenshots} });
        my $storage = $file->getStorageLocation;
        my @files;
        @files = @{ $storage->getFiles } if (defined $storage);
        $var->{screenshotsUrl}      = $self->getUrl('func=viewScreenshots');
        $var->{screenshotThumbnail} = $storage->getUrl('thumb-'.$files[0]);
    }
        
    # Rating form

    my %rating;
    tie %rating, 'Tie::IxHash';
    %rating = (
        1=>"1 - ".$i18n->get('worst label'),
                2=>2,
                3=>3,
                4=>4,
                5=>"5 - ".$i18n->get('respectable label'),
                6=>6,
                7=>7,
                8=>8,
                9=>9,
                10=>"10 - ".$i18n->get('best label')
        );
    my $ratingsTable = "<table class='ratingForm'><tbody>\n
        <tr><th></th><th>".$i18n->get('mean label')."</th>
        <th>".$i18n->get('median label')."</th>
        <th>".$i18n->get('count label')."</th></tr>\n";

    my $ratingForm = WebGUI::HTMLForm->new($session,
        -extras     =>'class="content"',
        -tableExtras=>'class="content"'
        );
    $ratingForm = WebGUI::HTMLForm->new($session,
        -extras     =>'class="ratingForm"',
        -tableExtras=>'class="ratingForm"'
        );
    $ratingForm->hidden(
        -name       =>"listingId",
        -value      =>$self->getId
        );
    $ratingForm->hidden(
        -name       =>"func",
        -value      =>"rate"
        );
    foreach my $category (@categories) {
        my ($mean,$median,$count) = $db->quickArray("select meanValue, medianValue, countValue 
            from MatrixListing_ratingSummary
            where listingId=? and category=?",[$self->getId,$category]);
        $ratingsTable .= '<tr><th>'.$category.'</th><td>'.$mean.'</td><td>'.$median.'</td><td>'.$count.'</td></tr>';
        $ratingForm->selectBox(
            -name   =>$category,
            -label  =>$category,
            -value  =>[5],
            -extras =>'class="ratingForm"',
            -options=>\%rating
            );
    }
    $ratingsTable .= '</tbody></table>';
    $ratingForm->submit(
        -extras =>'class="ratingForm"',
        -value  =>$i18n->get('rate submit label'),
        -label  =>'<a href="'.$self->getUrl("showRatings=1").'">'.$i18n->get('show ratings').'</a>'
        );
    if ($hasRated || $session->form->process('showRatings')) {
        $var->{ratings} = $ratingsTable;
    } else {
        $var->{ratings} = $ratingForm->print;
    }

    # Mail form

    my $mailForm = WebGUI::HTMLForm->new($session,
        -extras     =>'class="content"',
        -tableExtras=>'class="content"'
        );
    $mailForm->hidden(
        -name       =>"func",
        -value      =>"sendEmail"
        );
    $mailForm->captcha(
        -name       =>"verify"
        );
    $mailForm->email(
        -extras     =>'class="content"',
        -name       =>"from",
        -value      =>$session->user->get("email"),
        -label      =>$i18n->get('your email label'),
        );
    $mailForm->selectBox(
        -name       =>"subject",
        -extras     =>'class="content"',
        -options    =>{
            $i18n->get('report error label')      =>$i18n->get('report error label'),
            $i18n->get('general comment label')   =>$i18n->get('general comment label'),
            },
        -label      =>$i18n->get('request type label'),
        );
    $mailForm->textarea(
        -rows       =>4,
        -extras     =>'class="content"',
        -columns    =>35,
        -name       =>"body",
        -label      =>$i18n->get('comment label'),
        );
    $mailForm->submit(
        -extras     =>'class="content"',
        -value      =>$i18n->get('send button label'),
        );
    $var->{emailForm} = $mailForm->print;

    my $template = $self->processTemplate($var,undef, $self->{_viewTemplate});
	return $self->getParent->processStyle($template);
}


#-------------------------------------------------------------------

=head2 www_click ( )

Redirects to the manufacturerUrl or productUrl and increments clicks.

=cut

sub www_click {
    my $self    = shift;

    return $self->session->privilege->noAccess() unless $self->canView;

    my $session = $self->session;

    $self->incrementCounter('clicks');
    if ($session->form->process("manufacturer")) {
        $session->response->setRedirect( $self->get('manufacturerURL') );
    }
    else {
        $session->response->setRedirect( $self->get('productURL') );
    }
    return undef;
}

#-------------------------------------------------------------------

=head2 www_deleteStickied  (  )

Sets the sort scratch variable.

=cut

sub www_deleteStickied {

    my $self = shift;
    
    return $self->session->privilege->noAccess() unless $self->canView;
    $self->getParent->www_deleteStickied();

    return undef;
}

#-------------------------------------------------------------------

=head2 www_getAttributes ( )

Gets a listings attributes grouped by category as json.

=cut

sub www_getAttributes {
    
    my $self    = shift;
    my $session = $self->session;
    my $db      = $session->db;

    return $session->privilege->noAccess() unless $self->canView;

    $session->response->content_type("application/json");

    my @results;
    my @categories  = keys %{$self->getParent->getCategories};
    foreach my $category (@categories) {
        push(@results,{label=>$category,fieldType=>'category'});
        my $attributes;
        my @attribute_loop;
        $attributes = $db->read("select * from Matrix_attribute as attribute
            left join MatrixListing_attribute as listing using(attributeId)
            where listing.matrixListingId = ? and category =? and attribute.assetId = ?",
            [$self->getId,$category,$self->getParent->getId]);
        while (my $attribute = $attributes->hashRef) {
            $attribute->{label} = $attribute->{name};
            $attribute->{attributeId} =~ s/-/_____/g;
            if ($attribute->{fieldType} eq 'MatrixCompare'){
                $attribute->{compareColor} = $self->getParent->getCompareColor($attribute->{value});
                $attribute->{value} = WebGUI::Form::MatrixCompare->new($self->session,$attribute)->getValueAsHtml;
            }
            if($session->scratch->get('stickied_'.$attribute->{attributeId})){
                $attribute->{checked} = 'checked';
            }
            else{
                $attribute->{checked} = '';
            }
            push(@results,$attribute);
        }
    }
    my $jsonOutput;
    $jsonOutput->{ResultSet} = {Result=>\@results};

    return JSON->new->encode($jsonOutput);
}

#-------------------------------------------------------------------

=head2 www_getScreenshots ( )

Returns the screenshots as xml.

=cut

sub www_getScreenshots {
    my $self = shift;

    return $self->session->privilege->noAccess() unless $self->canView;

    $self->session->response->content_type('text/xml');

    my $xml = qq |<?xml version="1.0" encoding="UTF-8"?>
<content>
    <slides>
|;

    if ( $self->get('screenshots') ) {
        my $fileObject = WebGUI::Form::File->new($self->session,{ value=>$self->get('screenshots') });
        my $storage = $fileObject->getStorageLocation;
        my $path = $storage->getPath;
        my @files;
        @files = @{ $storage->getFiles } if (defined $storage);
        foreach my $file (@files) {
        unless ($file =~ m/^thumb-/){
            my ($width, $height) = $storage->getSizeInPixels($file);
            my $thumb = 'thumb-'.$file;
            $xml .= "
        <slide>
            <title></title>
            <description><![CDATA[ Screenshots ]]></description>
            <image_source>".$storage->getUrl($file)."</image_source>
            <duration>5</duration>
            <thumb_source>".$storage->getUrl($thumb)."</thumb_source>
            <width>".$width."</width>
            <height>".$height."</height>
        </slide>
            ";
            }
        }
    }

    $xml .= qq |
    </slides>
</content>
|;

    return $xml;
}

#-------------------------------------------------------------------

=head2 www_getScreenshotsConfig ( )

Returns the xml config file for the ukplayer that displays the screenshots.

=cut

sub www_getScreenshotsConfig {
    my $self    = shift;
    my $var     = $self->get;

    return $self->session->privilege->noAccess() unless $self->canView;

    $self->session->response->content_type('text/xml');

    return $self->processTemplate($var,$self->getParent->get("screenshotsConfigTemplateId"));
}

#-------------------------------------------------------------------

=head2 www_rate ( )

Saves a rating of a matrix listing and returns the listing view.

=cut

sub www_rate {
    my $self = shift;
    my $form = $self->session->form;

    return $self->session->privilege->noAccess() unless $self->canView;
    
    my $hasRated    = $self->hasRated;
    my $sameRating  = 1;
    my $first       = 1;
    my $lastRating;
    
    foreach my $category (keys %{$self->getParent->getCategories}) {
        if ($first) {
            $first=0;
        } else {
            if ($lastRating != $form->process($category)) {
                $sameRating = 0;
            }
        }
        $lastRating = $form->process($category);
    }
    
    # Throw out ratings that are all the same number, or if the user rates twice.
    unless ($hasRated || $sameRating) {
        $self->setRatings($self->session->form->paramsHashRef);
    }

    $self->prepareView;
    return $self->view;
}

#-------------------------------------------------------------------

=head2 www_sendEmail ( )

Sends an email to the maintainer of this matrix listing and returns www_view

=cut

sub www_sendEmail {
    my $self = shift;
    my $form = $self->session->form;

    return $self->session->privilege->noAccess() unless $self->canView;
    
    if ($form->process("verify","captcha")) {
        if ($form->process("body") ne "") {
            my $user = WebGUI::User->new($self->session, $self->get('maintainerId'));
            my $mail = WebGUI::Mail::Send->create($self->session,{
                        to      =>$user->get("email"),
                        subject =>$self->get('productName')." - ".$form->process("subject"),
                        from=>$form->process("from")
                });
            $mail->addText($form->process("body"));
            $mail->addFooter;
            $mail->queue;
        }
    }

    $self->prepareView;
    return $self->view(0,1);
}
#-------------------------------------------------------------------

=head2 www_setStickied  (  )

Sets the sort scratch variable.

=cut

sub www_setStickied {

    my $self = shift;

    return $self->session->privilege->noAccess() unless $self->canView;
    $self->getParent->www_setStickied();

    return undef;
}
#-------------------------------------------------------------------

=head2 www_view ( )

Web facing method which is the default view page.  This method does a 
302 redirect to the "showPage" file in the storage location.

=cut

sub www_view {
	my $self = shift;

	return $self->session->privilege->noAccess() unless $self->canView;

    $self->prepareView;
	return $self->view;
}

#-------------------------------------------------------------------

=head2 www_viewScreenshots ( )

Returns this listing's screenshots in a ukplayer.

=cut

sub www_viewScreenshots {
    my $self    = shift;
    my $var     = $self->get;
    
    $var->{configUrl} = 'config='.$self->getUrl("func=getScreenshotsConfig");

    return $self->session->privilege->noAccess() unless $self->canView;

    return $self->processTemplate($var,$self->getParent->get("screenshotsTemplateId"));
}

__PACKAGE__->meta->make_immutable;
1;

#vim:ft=perl
