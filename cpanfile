requires 'Carp';
requires 'Class::Load';
requires 'File::ShareDir';
requires 'FindBin';
requires 'Mojo::Base';
requires 'Mojolicious';
requires 'Mojolicious::Plugin::Disqus::Tiny';
requires 'Mojolicious::Plugin::GoogleAnalytics';
requires 'Mojolicious::Plugin::Gravatar';
requires 'Mojolicious::Plugin::CSRFProtect';
requires 'Mojolicious::Plugin::HTMLLint';
requires 'Mojolicious::Plugin::Bcrypt';
requires 'Path::Tiny';
requires 'Text::MultiMarkdown';
requires 'Mango', '0.12';
requires 'String::Dirify';
requires 'Method::Signatures';
requires 'DateTime';
requires 'DateTime::Format::RFC3339';
requires 'XML::Atom::SimpleFeed';
requires 'String::Util';
requires 'Text::Sass::XS';
requires 'IO::Prompt';

on develop => sub {
    requires 'Test::Pod', '1.41';
    requires 'Test::Mojo';
};
