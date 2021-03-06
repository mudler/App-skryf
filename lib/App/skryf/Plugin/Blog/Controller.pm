package App::skryf::Plugin::Blog::Controller;

use Mojo::Base 'Mojolicious::Controller';
use Method::Signatures;
use XML::Atom::SimpleFeed;
use DateTime::Format::RFC3339;
use Encode;

method blog_splash {
    my $posts = $self->db('Post')->this_year(7);
    $self->render('blog/splash', postlist => $posts);
}

method blog_index {
    my $posts = $self->db('Post')->all;
    $self->render('blog/index', postlist => $posts);
}

method blog_detail {
    my $slug = $self->param('slug');
    unless ($slug =~ /^[A-Za-z0-9_-]+$/) {
        $self->render(text => 'Invalid post name!', status => 404);
        return;
    }
    my $post  = $self->db('Post')->get($slug);
    unless ($post) {
        $self->render(text => 'No post found!', status => $post);
    }

    $self->stash(post => $post);
    $self->render('blog/detail');
}

method blog_feeds_by_cat {
    my $category = $self->param('category');
    my $posts    = $self->db('Post')->by_cat($category);
    my $feed     = App::skryf::Util->feed($self->config, $posts);
    $self->render(text => $feed->as_string, format => 'xml');
}

method blog_feeds {
    my $posts = $self->db('Post')->all;
    my $feed  = App::skryf::Util->feed($self->config, $posts);
    $self->render(text => $feed->as_string, format => 'xml');
}

method admin_blog_index {
    $self->stash(postlist => $self->db('Post')->all);
    $self->render('blog/admin_index');
}

method admin_blog_new {
    my $method = $self->req->method;
    if ($method eq "POST") {
        my $topic   = $self->param('topic');
        my $content = $self->param('content');
        my $tags    = $self->param('tags');
        $self->db('Post')->create($topic, $content, $tags);
        $self->redirect_to('admin_blog_index');
    }
    else {
        $self->render('blog/new');
    }
}

method admin_blog_edit {
    my $slug  = $self->param('slug');
    $self->stash(post => $self->db('Post')->get($slug));
    $self->render('blog/edit');
}

method admin_blog_update {
    my $slug  = $self->param('slug');
    my $model = $self->db('Post');
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
    my $slug  = $self->param('slug');
    my $model = $self->db('Post');
    if ($model->remove($slug)) {
        $self->flash(message => 'Removed: ' . $slug);
    }
    else {
        $self->flash(message => 'Failed to remove post.');
    }
    $self->redirect_to('admin_blog_index');
}

1;
__END__

=head1 NAME

App::skryf::Plugin::Blog::Controller - blog plugin controller

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
