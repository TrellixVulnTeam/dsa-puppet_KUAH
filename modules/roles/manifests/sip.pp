class roles::sip {
	@ferm::rule { 'sip-ws':
		domain      => 'ip',
		description => 'SIP over WebSocket (for WebRTC)',
		rule        => 'proto tcp mod state state (NEW) dport (443)'
	}
	@ferm::rule { 'sip':
		domain      => 'ip',
		description => 'SIP connections (TLS)',
		rule        => 'proto tcp mod state state (NEW) dport (5061)'
	}
	@ferm::rule { 'turn':
		domain      => 'ip',
		description => 'TURN connections (TLS)',
		rule        => 'proto tcp mod state state (NEW) dport (5349)'
	}
	@ferm::rule { 'rtp':
		domain      => 'ip',
		description => 'RTP streams',
		rule        => 'proto udp mod state state (NEW) dport (49152:65535)'
	}
}
