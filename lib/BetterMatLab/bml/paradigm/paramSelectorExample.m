function [Ps, nam, params] = paramSelectorExample

params = varargin2S({
    'parad_time', varargin2S({
        'VD', varargin2S({
            'parad_time',       '''VD''' % To be evaluate into a string, we need triple single quotation marks
            'tAllowExitFrom',   '0'
			'tAllowExitUntil',  'P.tClockDur' % Can use P.(previously_determined_field)
			'tAllowEnterFrom',  '0'
			'tAllowEnterUntil', 'P.tClockDur'
			'tGoBeepDur',       '0.05'
            })
        'RT', varargin2S({
            'parad_time',       '''RT'''
            'tAllowExitFrom',   '0'
			'tAllowExitUntil',  'P.tClockDur'
			'tAllowEnterFrom',  '0'
			'tAllowEnterUntil', 'P.tClockDur'
			})
        'cued', varargin2S({
            'parad_time',       '''cued'''
            'tAllowExitFrom',   '0'
			'tAllowExitUntil',  'P.tClockDur'
			'tAllowEnterFrom',  '0'
			'tAllowEnterUntil', 'P.tClockDur'
            'tBeep',            '4'
            'tBeepDur',         '0.05'
            'tInterBeep',       '0.5'
            'tHome2Beep',       '0.5'
            })
        })
    'max_coh',    '0.512' % Will go through eval(). Note: use consistent notation for a same number.
    'min_coh',    '0'
    'n_coh',      '5'
    'sym_coh',    '1'
    'tRDKDur', varargin2S({
        'short', varargin2S({
            'tRDKDurMin', '0.2'
            'tRDKDurAvg', '0.3'
            'tRDKDurMax', '0.5'
            'tRDKDur',    '0.3'
            })
        'long', varargin2S({
            'tRDKDurMin', '0.1'
            'tRDKDurAvg', '0.4'
            'tRDKDurMax', '0.8'
            'tRDKDur',    '0.4'
            })
        });
    'showClock',  '1'
    'tClockDur'   '2.5'
    'tClock2RDK', '0'
    'etc', varargin2S({
        'default', varargin2S({
            'feat', '''M'''
            })
        })
    });