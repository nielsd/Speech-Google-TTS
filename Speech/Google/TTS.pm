package Speech::Google::TTS;

#
# Module that uses Google Translate for text to speech synthesis.
#
# Copyright (C) 2013, by Niels Dettenbach <nd@syndicat.com> 
# with contributes of Lefteris Zafiris <zaf.000@gmail.com>
#
# This program is free software, distributed under the terms of
# the GNU General Public License Version 2.
#

use warnings;
use strict;
use File::Temp qw(tempfile tempdir);
use CGI::Util qw(escape);
use LWP::UserAgent;
use LWP::ConnCache;

my @text;

# init
sub new {
        my ($class) = @_;
        my $self = {};
        bless $self, $class;

        $self->{'samplerate'}           = 16000;
        $self->{'speed'}                = 1.2;
        $self->{'lang'}                 = "en";
        $self->{'tmpdir'}        	= tempdir( CLEANUP =>  0 );;
        $self->{'timeout'}    		= "10";
        $self->{'googleurl'} 		= "http://translate.google.com/translate_tts";
        $self->{'languages'}		= languages();
	$self->{'auformat'}		= "wav";
        $self->{'mpg123'}               = "/usr/bin/mpg123";
        $self->{'sox'}                  = "/usr/bin/sox";
	$self->{'soxargs'}		= '';
        return($self);
}


sub say_text {
	my ($self, @text) = @_;
	my @mp3list;
	my @soxargs;
	my $samplerate		= $self->{'samplerate'};
	my $filename		= '';
	my $wav_name;
	my $lang		= $self->{'lang'};
	my $speed       	= $self->{'speed'};
        my $tmpdir		= $self->{'tmpdir'};
        my $timeout		= $self->{'timeout'};
        my $url			= $self->{'googleurl'};
	my $mpg123		= $self->{'mpg123'};
	my $sox			= $self->{'sox'};
	my $soxargs		= $self->{'soxargs'};
	
	for (@text) {
		# Split input text to comply with google tts requirements #
		s/[\\|*~<>^\n\(\)\[\]\{\}[:cntrl:]]/ /g;
		s/\s+/ /g;
		s/^\s|\s$//g;
		if (!length) {
			print "No text passed for synthesis.";
			return;
		}
		$_ .= "." unless (/^.+[.,?!:;]$/);
		@text = /.{1,100}[.,?!:;]|.{1,100}\s/g;

		my $ua = LWP::UserAgent->new;
		$ua->agent("Mozilla/5.0 (X11; Linux; rv:8.0) Gecko/20100101");
		$ua->env_proxy;
		$ua->conn_cache(LWP::ConnCache->new());
		$ua->timeout($timeout);

		foreach my $line (@text) {
			# Get speech data from google and save them in temp files #
			$line =~ s/^\s+|\s+$//g;
			next if (length($line) == 0);
			$line = escape($line);
	
			my ($mp3_fh, $mp3_name) = tempfile(
				"tts_XXXXXX",
				DIR    => $tmpdir,
				SUFFIX => ".mp3",
				UNLINK => 0
			);
			my $request = HTTP::Request->new('GET' => "$url?tl=$lang&q=$line");
			my $response = $ua->request($request, $mp3_name);
			if (!$response->is_success) {
				print "Failed to fetch speech data.";
				return $self;
			} else {
				push(@mp3list, $mp3_name);
			}
		}


		# decode mp3s and concatenate #
		my ($wav_fh, $wav_name) = tempfile(
			"tts_XXXXXX",
			DIR    => $tmpdir,
			SUFFIX => ".wav",
			UNLINK => 0
		);
		$self->{'filename'} = $wav_name;


		# as WAV
		if ($self->{'auformat'} eq 'wav') {
			if (system($mpg123, "-q", "-w", $wav_name, @mp3list)) {
				print "mpg123 failed to process sound file to WAV.";
				return;
			}
		}

		# as MP3
		elsif ($self->{'auformat'} eq 'mp3') {
                        if (system($mpg123, "-q", $wav_name, @mp3list)) {
                                print "mpg123 failed to process sound file to WAV.";
                                return;
			}
                }


		elsif ($self->{'auformat'} eq 'sox') {
	#		# Set sox args and process wav file 
	#		@soxargs = ($sox, "-q", $wav_name);
	#		push(@soxargs, ("tempo", "-s", $speed)) if ($speed != 1);
	#		push(@soxargs, ("rate", $samplerate)) if ($samplerate);
	#		if (system(@soxargs)) {
	#			print "sox failed to process sound file.";
	#			return;
	#		}
		}
	}
	return($self);
}

sub as_filename {
        my ($self) = @_;
	my $filename = $self->{'filename'};
	return $filename;
}

sub languages {
	my ($self) = @_;
	# the list of currently supported languages to the user or return it as a hash #
	my %sup_lang = (
		"Afrikaans",             "af",         "Albanian",             "sq",
		"Amharic",               "am",         "Arabic",               "ar",
		"Armenian",              "hy",         "Azerbaijani",          "az",
		"Basque",                "eu",         "Belarusian",           "be",
		"Bengali",               "bn",         "Bihari",               "bh",
		"Bosnian",               "bs",         "Breton",               "br",
		"Bulgarian",             "bg",         "Cambodian",            "km",
		"Catalan",               "ca",         "Chinese (Simplified)", "zh-CN",
		"Chinese (Traditional)", "zh-TW",      "Corsican",             "co",
		"Croatian",              "hr",         "Czech",                "cs",
		"Danish",                "da",         "Dutch",                "nl",
		"English",               "en",         "Esperanto",            "eo",
		"Estonian",              "et",         "Faroese",              "fo",
		"Filipino",              "tl",         "Finnish",              "fi",
		"French",                "fr",         "Frisian",              "fy",
		"Galician",              "gl",         "Georgian",             "ka",
		"German",                "de",         "Greek",                "el",
		"Guarani",               "gn",         "Gujarati",             "gu",
		"Hacker",                "xx-hacker",  "Hausa",                "ha",
		"Hebrew",                "iw",         "Hindi",                "hi",
		"Hungarian",             "hu",         "Icelandic",            "is",
		"Indonesian",            "id",         "Interlingua",          "ia",
		"Irish",                 "ga",         "Italian",              "it",
		"Japanese",              "ja",         "Javanese",             "jw",
		"Kannada",               "kn",         "Kazakh",               "kk",
		"Kinyarwanda",           "rw",         "Kirundi",              "rn",
		"Klingon",               "xx-klingon", "Korean",               "ko",
		"Kurdish",               "ku",         "Kyrgyz",               "ky",
		"Laothian",              "lo",         "Latin",                "la",
		"Latvian",               "lv",         "Lingala",              "ln",
		"Lithuanian",            "lt",         "Macedonian",           "mk",
		"Malagasy",              "mg",         "Malay",                "ms",
		"Malayalam",             "ml",         "Maltese",              "mt",
		"Maori",                 "mi",         "Marathi",              "mr",
		"Moldavian",             "mo",         "Mongolian",            "mn",
		"Montenegrin",           "sr-ME",      "Nepali",               "ne",
		"Norwegian",             "no",         "Norwegian (Nynorsk)",  "nn",
		"Occitan",               "oc",         "Oriya",                "or",
		"Oromo",                 "om",         "Pashto",               "ps",
		"Persian",               "fa",         "Pirate",               "xx-pirate",
		"Polish",                "pl",         "Portuguese (Brazil)",  "pt-BR",
		"Portuguese (Portugal)", "pt-PT",      "Portuguese",           "pt",
		"Punjabi",               "pa",         "Quechua",              "qu",
		"Romanian",              "ro",         "Romansh",              "rm",
		"Russian",               "ru",         "Scots Gaelic",         "gd",
		"Serbian",               "sr",         "Serbo-Croatian",       "sh",
		"Sesotho",               "st",         "Shona",                "sn",
		"Sindhi",                "sd",         "Sinhalese",            "si",
		"Slovak",                "sk",         "Slovenian",            "sl",
		"Somali",                "so",         "Spanish",              "es",
		"Sundanese",             "su",         "Swahili",              "sw",
		"Swedish",               "sv",         "Tajik",                "tg",
		"Tamil",                 "ta",         "Tatar",                "tt",
		"Telugu",                "te",         "Thai",                 "th",
		"Tigrinya",              "ti",         "Tonga",                "to",
		"Turkish",               "tr",         "Turkmen",              "tk",
		"Twi",                   "tw",         "Uighur",               "ug",
		"Ukrainian",             "uk",         "Urdu",                 "ur",
		"Uzbek",                 "uz",         "Vietnamese",           "vi",
		"Welsh",                 "cy",         "Xhosa",                "xh",
		"Yiddish",               "yi",         "Yoruba",               "yo",
		"Zulu",                  "zu"
	);
	return %sup_lang;
}

1;
