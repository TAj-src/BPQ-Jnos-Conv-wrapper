
#!/usr/bin/perl -w -T
use strict;

$ENV{PATH} = '/bin';


use IO::Socket;
use IO::Select;
use IO::Handle;

my $socket = IO::Socket::INET->new(
                 PeerAddr    => 'pe1rrr.red-heat.com',
                 PeerPort    =>  3600,
                 Proto       => 'tcp',
                 Timeout     =>  2
             )
             or die "Could not connect";


my $select = IO::Select->new();

$| = 1; # Autoflush

#set autoflush
my $old_fh = select(STDOUT);
$| = 1;
select($old_fh);


$select -> add ($socket);

# Read Callsign of connecting station
my $call = <STDIN>;
$call =~ s/^\s*//;
$call =~ s/\s*$//;
print $socket "/n $call 3333\n";

$select -> add (\*STDIN);  # Does not work on Windows! [ http://stackoverflow.com/a/1701458/180275 ]

my $buf;

while (1) {
  while (my @ready = $select -> can_read(2)) {

    foreach my $fh (@ready) {
       if ($fh == $socket) {

          $socket->recv($buf,1024);
          if (length $buf == 0 )  {
                die "Bye1\n";

          }

          unless (print "$buf"  ) {
                die "Bye2\n";
          }

       }
       else {

         my $buf = <STDIN>;
         print $socket $buf or die "Bye!\n";

       }
    }
  }
  #print "$!\n";
}
