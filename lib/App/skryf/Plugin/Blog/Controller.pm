package App::skryf::Plugin::Blog::Controller;

use Mojo::Base 'Mojolicious::Controller';
use Method::Signatures;
use App::skryf::Model::Post;

method blog_index {
    my $model = App::skryf::Model::Post->new;
    my $posts = $model->all;
    $self->stash(postlist => $posts);
    $self->render('blog_index');
}

method blog_detail {
    my $slug = $self->param('id');
    unless ($slug =~ /^[A-Za-z0-9_-]+$/) {
        $self->render(text => 'Invalid post name!', status => 404);
        return;
    }
    my $model = App::skryf::Model::Post->new;
    my $post = $model->find_one({slug => $slug});
    unless ($post) {
        $self->render(text => 'No post found!', status => $post);
    }

    $self->stash(post => $post);
    $self->render('blog_detail');
}

method blog_feeds_by_cat {
    my $category = $self->param('category');
    my $model = App::skryf::Model::Post->new;
    my $posts   = $model->find({category => $category})->all;
    $self->stash(postlist => $posts);
    $self->render(template => 'atom', format => 'xml');
}

method blog_feeds {
    my $model = App::skryf::Model::Post->new;

    $self->stash(postlist => $model->all);
    $self->render(template => 'atom', format => 'xml');
}

method admin_blog_index {
    my $model = App::skryf::Model::Post->new;
    $self->stash(postlist => $model->all);
    $self->render('admin/index');
}

method admin_blog_new {
    my $method = $self->req->method;
    if ($method eq "POST") {
        my $topic   = $self->param('topic');
        my $content = $self->param('content');
        my $tags    = $self->param('tags');
        my $model   = App::skryf::Model::Post->new;
        $model->create($topic, $content, $tags);
        $self->redirect_to('admin/index');
    }
    else {
        $self->render('admin/new');
    }
}

method admin_blog_edit {
    my $slug = $self->param('id');
    my $model   = App::skryf::Model::Post->new;
    $self->stash(post => $model->get($slug));
    $self->render('admin/edit');
}

method admin_blog_update {
    my $slug  = $self->param('slug');
    my $model = App::skryf::Model::Post->new;
    my $post  = $model->get($slug);
    $post->{topic}   = $self->param('topic');
    $post->{content} = $self->param('content');
    $post->{tags}    = $self->param('tags');
    $model->save($post);
    $self->flash(message => "Blog " . $self->param('topic') . " updated.");
    $self->redirect_to(
        $self->url_for('admin_blog_edit', {slug => $post->{slug}}));
}

method admin_blog_delete {
    my $slug = $self->param('slug');
    my $model = App::skryf::Model::Post->new;
    if ($model->remove($slug)) {
        $self->flash(message => 'Removed: '. $slug);
    }
    else {
        $self->flash(message => 'Failed to remove post.');
    }
    $self->redirect_to($self->blogconf->{adminPathPrefix});
}

1;
__END__

=head1 NAME

Mojolicious::Plugin::Blog::Controller - blog plugin controller

=head1 DESCRIPTION

Simple controller class for handling listing, viewing, and administering
blog posts.

=head1 CONTROLLERS

=head2 B<blog_index>

=head2 B<blog_archive>

=head2 B<blog_detail>

=head2 B<admin_blog_new>

=head2 B<admin_blog_edit>

=head2 B<admin_blog_update>

=head2 B<admin_blog_delete>

=cut