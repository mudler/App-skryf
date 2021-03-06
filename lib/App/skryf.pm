package App::skryf;

use Mojo::Base 'Mojolicious';

use Carp;
use File::ShareDir ':ALL';
use Path::Tiny;
use Class::Load ':all';

our $VERSION = '0.014_01';

has admin_menu => sub {
  my $self = shift;
  return [];
};

has frontend_menu => sub {
  my $self = shift;
  return [];
};

sub startup {
    my $self = shift;

###############################################################################
# Setup configuration
###############################################################################
    my $cfgfile = undef;
    if ($self->mode eq "development") {
        $cfgfile = path(dist_dir('App-skryf'), 'app/config/development.conf');
    }
    else {
        $cfgfile = path("~/.skryf.conf");
        path(dist_dir('App-skryf'), 'app/config/production.conf')->copy($cfgfile)
          unless $cfgfile->exists;
    }
    $self->plugin('Config' => {file => $cfgfile});
    my $cfg = $self->config->{skryf} || +{};
    $cfg->{version} = eval $VERSION;
    $self->secret($cfg->{secret});

###############################################################################
# Database Helper
###############################################################################
    $self->helper(
        db => sub {
            my $self       = shift;
            my $collection = shift;
            my $store      = "App::skryf::Model::$collection";
            load_class($store);
            $store->new(dbname => $cfg->{dbname});
        }
    );
###############################################################################
# Load global plugins
###############################################################################
    push @{$self->plugins->namespaces}, 'App::skryf::Plugin';
    for (keys %{$cfg->{extra_modules}}) {
        $self->plugin($_) if $cfg->{extra_modules}{$_} > 0;
    }

###############################################################################
# Load Core plugins
###############################################################################
    $self->plugin(
        'Search' => {
            tapir_token  => $cfg->{social}{tapir},
            tapir_secret => $cfg->{social}{tapir_secret}
        }
    );

###############################################################################
# Define template, media, static paths
###############################################################################
    my $template_directory = undef;
    my $media_directory    = undef;
    if ($self->mode eq "development" || !defined($cfg->{template_directory}))
    {
        $template_directory = path(dist_dir('App-skryf'), 'app/templates');
        $media_directory    = path(dist_dir('App-skryf'), 'app/public');
    }
    else {
        $template_directory = path($cfg->{template_directory});
        $media_directory    = path($cfg->{media_directory});
    }

    croak("A template|media|static directory must be defined.")
      unless $template_directory->is_dir
      && $media_directory->is_dir;

    push @{$self->renderer->paths}, $template_directory;
    push @{$self->static->paths},   $media_directory;

# use App::skryf::Command namespace
    push @{$self->commands->namespaces}, 'App::skryf::Command';

###############################################################################
# Routing
###############################################################################
    $self->helper(config => sub {$cfg});
    my $r = $self->routes;

    # Authentication
    # TODO: make pluggable
    $r->get('/login')->to('login#login')->name('login');
    $r->get('/logout')->to('login#logout')->name('logout');
    $r->post('/auth')->to('login#auth')->name('auth');

    # TODO: make splashpage overridable
    $r->get('/')->to(
        namespace => 'App::skryf::Plugin::Blog::Controller',
        action    => 'blog_splash'
    )->name('splashpage');
}
1;

__END__

=head1 NAME

App-skryf - i kno rite. another perl cms.

=head1 DESCRIPTION

Another CMS platform which utilizes Mojolicious, Markdown, hypnotoad, Rex, Ubic,
and Mongo.

=head1 PREREQS

I like L<http://perlbrew.pl>, but, whatever you're comfortable with. I won't judge.

=head1 INSTALLATION (BLEEDING EDGE)

    $ cpanm git://github.com/battlemidget/App-skryf.git

=head1 SETUP

    $ skryf setup

By default B<skryf> will look in dist_dir for templates and media. To override that
make sure I<~/.skryf.conf> points to the locations of your templates and media.
For example: 

    $ mkdir -p ~/blog/{templates,public}

Edit ~/.skryf.conf to reflect those directories in I<template_directory> and 
I<media_directory>.

    template_directory => '~/blog/templates',
    media_directory    => '~/blog/public',

So B<~/blog/templates/blog/detail.html.ep> and B<~/blog/public/style.css>

=head1 DEPLOY

    $ export BLOGUSER=username
    $ export BLOGSERVER=example.com

    If perlbrew is installed Rex will autoload that environment to use remotely.
    Otherwise more tinkering is required to handle the perl environment remotely.
    $ rexify --use=Rex::Lang::Perl::Perlbrew
    $ rex deploy

=head1 RUN (Development)

    $ skryf daemon

=head1 RUN (Production)

I use Ubic to manage the process

     use Ubic::Service::SimpleDaemon;
     my $service = Ubic::Service::SimpleDaemon->new(
      bin => "hypnotoad -f `which skryf`",
      cwd => "/home/username",
      stdout => "/tmp/blog.log",
      stderr => "/tmp/blog.err.log",
      ubic_log => "/tmp/blog.ubic.log",
      user => "username"
     );

=head1 AUTHOR

Adam Stokes E<lt>adamjs@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2013- Adam Stokes

=head1 LICENSE

Licensed under the same terms as Perl.

=begin html

<img src="https://travis-ci.org/battlemidget/App-skryf.png?branch=master" />

=end html

=cut
