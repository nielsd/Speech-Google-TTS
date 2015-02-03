Speech-Google-TTS
-----------------
Perl Module which uses Google Transaltion API as a high level Text-to-Speech Engine

                Speech::Google::TTS
                 v0.7 (21.11.2013)

This Module allows to use the Google TTS service behind the
Google Translation service from Perl and is the core of the
following Speech::Google Text to Speech Module set.

SOFTWARE REQUIREMENTS
---------------------
 * mpg123 or mpg321


SOFTWARE OPTIONS
----------------
 * sox


USAGE:
======
A simple example:

        use Speech::Google::TTS

        $a = new Speech::Google::TTS();

        $a->say_text("speak this text!");
        $a->as_filename();

        $a->{'lang'} = 'de';
        $a->say_text("sprich diesen Text");
        $a->as_filename();


MORE OPTIONS/CONFIGURATION
--------------------------
List of available parameters / options:

        $a->{'samplerate'}      sample rate in kHz (16000)
        $a->{'lang'}            language ('en')
        $a->{'speed'}           speed of speech (1.2)
        $a->{'tmpdir'}          temp directory (/var/tmp)
        $a->{'timeout'}         timeout google connect in s (10)
        $a->{'googleurl'}       google url
        $a->{'mpg123'}          mpg123 path ('/usr/bin/mpg123')
        $a->{'sox'}             sox path ('/usr/bin/sox')
        $a->{'soxargs'}         sox args ('')

More comfort and documentation will follow as it is still 
available here (but have to be fitted for public usage).

All stuff is licensed under the GPL.

Feel free to visit the project website 

  http://www.syndicat.com/open_source/google/perl/googletts/

or write to 

  googletts@syndicat.com 

good luck!


Niels Dettenbach
<nd@syndicat.com>
