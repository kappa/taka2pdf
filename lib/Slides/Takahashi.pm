package Slides::Takahashi::Line;
use strict;
use warnings;

use List::Util qw/sum/;

use base qw/Class::Accessor/;
__PACKAGE__->mk_accessors(qw/text _hboxes/);

sub parse {
    my ($class, $text) = @_;

    my $self = $class->new({ text => $text });

    $self->{_hboxes} = [ map { Slides::Takahashi::Hbox->parse($_) }
        split(/(\[\[\w+:.*:\w+\]\])/, $text) ];

    use Data::Dumper;
    print Dumper($self->{_hboxes});

    return $self;
}

sub width_1 {
    my ($self, $style) = @_;

    return 
        sum(map { $_->width_1($style) } @{$self->{_hboxes}});
}

sub width {
    my ($self, $style) = @_;

    return 
        sum(map { $_->width($style) } @{$self->{_hboxes}});
}

sub render {
    my ($self, $pdf_ctx, $style) = @_;

    $_->render($pdf_ctx, $style) foreach @{$self->{_hboxes}};
}

package Slides::Takahashi::Hbox;
use base qw/Class::Accessor/;
__PACKAGE__->mk_accessors(qw/text type/);

our $HBOX_NORMAL    = 1;
our $HBOX_EM        = 2;

sub parse {
    my ($class, $text) = @_;

    my $self = $class->new;

    if ($text =~ /^\[\[EM:(.*):EM\]\]$/s) {
        $self->text($1);
        $self->type($HBOX_EM);
    }
    else {
        $self->text($text);
        $self->type($HBOX_NORMAL);
    }

    return $self;
}

sub width_1 {
    my ($self, $style) = @_;

    if    ($self->type == $HBOX_EM) {
        return $style->{em_font}->width($self->text);
    }

    return $style->{normal_font}->width($self->text);
}

sub width {
    my ($self, $style) = @_;

    return $self->width_1($style) * $style->{font_size};
}

sub render {
    my ($self, $pdf_ctx, $style) = @_;

    $pdf_ctx->textstart;

    if ($self->type == $HBOX_EM) {
        $pdf_ctx->font($style->{em_font}, $style->{font_size});
    }
    else {
        $pdf_ctx->font($style->{normal_font}, $style->{font_size});
    }

    $pdf_ctx->text($self->text);

    $pdf_ctx->textend;

    $pdf_ctx->transform_rel(
        -translate => [$self->width($style), 0],
    );
}

1;
