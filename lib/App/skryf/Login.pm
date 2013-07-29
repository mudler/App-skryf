package App::skryf::Login;
use Mojo::Base 'Mojolicious::Controller';
use App::skryf::Model::User;

sub login {
  my $self = shift;
  $self->render('login');
}

sub logout {
  my $self = shift;
  $self->session(expires => 1);
  $self->redirect_to('index');
}

sub auth {
    my $self = shift;
    my $user = $self->param('username');
    my $pass = $self->param('password');

    my $model =
      App::skryf::Model::User->new(db => $self->users, username => $user);
    if ($model->check($pass)) {
        $self->session(user => 1);
        $self->redirect_to('admin_index');
    } else {
      $self->flash(message => 'failed auth.');
      $self->redirect_to('login');
    }
}

1;
