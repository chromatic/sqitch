package App::Sqitch::Plan::NodeList;

use v5.10.1;
use utf8;
use Carp;

sub new {
    my $class = shift;
    my (@list, %index);
    for my $node (@_) {
        push @list => $node;
        push @{ $index{ $node->format_name } } => $#list;
    }

    return bless {
        list   => \@list,
        lookup => \%index,
    }
}

sub count   { scalar @{ shift->{list} } }
sub items   { @{ shift->{list} } }
sub item_at { shift->{list}[shift] }

sub index_of {
    my ($self, $key, $tag) = @_;
    my $idx = $self->{lookup}{$key} or return undef;
    if (defined $tag) {
        return $idx->[-1] if $tag eq '@HEAD';
        my $tag_idx = $self->{lookup}{$tag} or croak qq{Unknown tag: "$tag"};
        $tag_idx = $tag_idx->[0];
        for my $i (reverse @{ $idx }) {
            return $i if $i < $tag_idx;
        }
        return undef;
    } else {
        return $idx->[0] if @{ $idx } < 2;
        croak qq{Key "$key" at multiple indexes};
    }
}

sub get {
    my $self = shift;
    my $idx = $self->index_of(@_) // return undef;
    return $self->{list}[ $idx ];
}

sub append {
    my ($self, $key, $val) = @_;
    my $list = $self->{list};
    push @{ $list } => $val;
    my $idx = $self->{lookup}{$key} ||= [];
    push $idx, $#$list;
}

1;

__END__

=head1 Name

App::Sqitch::Plan::NodeList - Sqitch deployment plan node list

=head1 Synopsis

  my $list = App::Sqitch::Plan::NodeList->new(
      $add_roles,
      $add_users,
      $insert_user,
      $alpha_tag,
      $insert_user2,
  );

  my @nodes = $list->items;
  my $add_users = $list->item_at(1);
  my $add_users = $list->get('add_users');

  my $insert_user1 = $list->get('insert_user', '@alpha');
  my $insert_user2 = $list->get('insert_user', '');

=head1 Description

This module is used internally by L<App::Sqitch::Plan> to manage plan nodes.
It's modeled on L<Array::AsHash> and L<Hash::MultiValue>, but makes allowances
for finding nodes relative to tags.

=head1 Interface

=head2 Constructors

=head3 C<new>

  my $plan = App::Sqitch::Plan::NodeList->new( @nodes );

Instantiates and returns a App::Sqitch::Plan::NodeList object with the list of
nodes. Each node should be a L<App::Sqitch::Plan::Step> or
L<App::Sqitch::Plan::Tag> object. Order will be preserved but the location of
each node will be indexed by its formatted name.

=head2 Instance Methods

=head3 C<count>

=head3 C<items>

=head3 C<item_at>

=head3 C<index_of>

=head3 C<get>

=head3 C<append>

=head1 See Also

=over

=item L<App::Sqitch::Plan>

The Sqitch plan.

=back

=head1 Author

David E. Wheeler <david@justatheory.com>

=head1 License

Copyright (c) 2012 iovation Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

=cut