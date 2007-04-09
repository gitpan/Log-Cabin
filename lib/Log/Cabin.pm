package Log::Cabin;

use 5.008005;
use strict;
use warnings;

require Exporter;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Log::Cabin ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.01';


# Preloaded methods go here.

use strict;
use Time::HiRes;
use Sys::Hostname;
use IO::Tee;
use Log::Cabin::Foundation;

my $_DEFAULT_LOG_CATEGORY = "Log::Cabin";
my $_IS_INIT=0;
my $OFF=0;
my $FATAL=1;
my $ERROR=2;
my $WARN=3;
my $INFO=4;
my $DEBUG=5;
my $ALL=6;

my $LEVELTEXT = {0=>'OFF',
		 1=>'FATAL',
		 2=>'ERROR',
		 3=>'WARN',
		 4=>'INFO',
		 5=>'DEBUG',
		 6=>'ALL'};

my $SINGLETON_INSTANCE=undef;
my @ALLLOGGERS;

sub new {
    my ($class) = shift;
    if($_IS_INIT == 1){
	return $SINGLETON_INSTANCE;
    }
    else{
	
	my $self = bless {}, ref($class) || $class;
	$self->_init(@_);

	if($self->{_SKIP_INIT}){
	}
	else{
	    $_IS_INIT=1;
	    $SINGLETON_INSTANCE = $self;
	    foreach my $loggerinst (@ALLLOGGERS){
		$loggerinst->set_logger_instance($SINGLETON_INSTANCE);
	    }
	}
	return $self;
    }
}

sub DESTROY{
     my $self = shift;
     if(defined $self->{_OUTPUT_HANDLE}){
	 close $self->{_OUTPUT_HANDLE};
     }

}

sub _init {
    my $self = shift;
    die if($_IS_INIT==1);
    $self->{_DEFAULT_LOG_LEVEL} = $WARN;
    $self->{_LOG_LEVEL} = $self->{_DEFAULT_LOG_LEVEL};
    $self->{_LOG_FILE} = undef;
    $self->{_HOSTNAME} = hostname;
    $self->{_PID} = $$;
    $self->{_CLOBBER} = 1;
    my %arg = @_;
    foreach my $key (keys %arg) {
        $self->{"_$key"} = $arg{$key};
    }
}

sub initialized{
    return $_IS_INIT;
}

sub get_instance{
    return $SINGLETON_INSTANCE;
}

sub set_file_output{
    my($self,$filename) = @_;
    $self->{_LOG_FILE} = $filename;
    my $filehandle;
    if($self->{_CLOBBER}){
	open($filehandle,"+>",$self->{_LOG_FILE})
	    or die "Can't open log file for writing $self->{_LOG_FILE}";
    }
    else{
	open($filehandle,">",$self->{_LOG_FILE})
	    or die "Can't open log file for writing $self->{_LOG_FILE}";
    }
    $self->{_OUTPUT_HANDLE} = $filehandle;
}

sub set_output{
    my($self,$handle) = @_;
    $self->{_OUTPUT_HANDLE} = $handle;
}

sub level{
    my($self,$level) = @_;
    if(defined $level && $level =~ /^\-*\d+$/){
	$self->{_LOG_LEVEL} = $level;
    }
    return $self->{_LOG_LEVEL};
}

sub more_logging{
    my($self,$level) = @_;
    if(defined $level && $level =~ /^\-*\d+$/){
	$self->{_LOG_LEVEL} += $level;
    }
}

sub less_logging{
    my($self,$level) = @_;
    if(defined $level && $level =~ /^\-*\d+$/){
	$self->{_LOG_LEVEL} -= $level;
    }
}

sub _output{
    my($self,$msg,$loggername,$level,$package,$filename,$line,$subroutine) = @_;
    my $datestamp = localtime(time());
    if(defined $self->{_OUTPUT_HANDLE}){
	print {$self->{_OUTPUT_HANDLE}} "$loggername $LEVELTEXT->{$level} $datestamp $self->{_HOSTNAME}:$self->{_PID} $filename:$package:$subroutine:$line || $msg\n";
    }
}

sub get_logger {
    my($class, @args) = @_;

    my $singleton;
    if(defined $SINGLETON_INSTANCE){
	$singleton = $SINGLETON_INSTANCE;
    }
    elsif(ref $class){
	$singleton = $class;
    }
    else{
	#die "get_logger called when Log::Log::Cabin not instantiated";
	$singleton = new Log::Cabin('SKIP_INIT'=>1);
    }
    if(!ref $class){

	@args = ($class,@args);
    }
    my $loggerinst = new Log::Cabin::Foundation($singleton,@args);
    push @ALLLOGGERS,$loggerinst;
    return $loggerinst;
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Log::Cabin - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Log::Cabin;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Log::Cabin, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Samuel Angiuoli, E<lt>angiuoli@tigr.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Samuel Angiuoli

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.5 or,
at your option, any later version of Perl 5 you may have available.


=cut
