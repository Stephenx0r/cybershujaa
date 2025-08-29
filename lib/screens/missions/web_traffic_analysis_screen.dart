import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/mission_models.dart';
import '../../utils/app_theme.dart';
import 'base_mission_screen.dart';

class WebTrafficAnalysisScreen extends BaseMissionScreen {
  const WebTrafficAnalysisScreen({
    super.key,
    required super.mission,
    super.isPractice,
  });

  @override
  ConsumerState<BaseMissionScreen> createStateImpl() => _WebTrafficAnalysisScreenState();
}

class _WebTrafficAnalysisScreenState extends BaseMissionScreenState<WebTrafficAnalysisScreen> {
  final List<NetworkPacket> _packets = [];
  final List<NetworkPacket> _filteredPackets = [];
  String _selectedFilter = 'all';
  bool _showPacketDetails = false;
  NetworkPacket? _selectedPacket;

  @override
  void initState() {
    super.initState();
    _initializePackets();
  }

  void _initializePackets() {
    _packets.addAll([
      NetworkPacket(
        id: 1,
        timestamp: '10:00:01',
        sourceIP: '192.168.1.100',
        destIP: '8.8.8.8',
        protocol: 'TCP',
        port: 443,
        size: 1500,
        flags: 'SYN',
        payload: 'GET /api/user HTTP/1.1',
        suspicious: false,
      ),
      NetworkPacket(
        id: 2,
        timestamp: '10:00:02',
        sourceIP: '192.168.1.50',
        destIP: '192.168.1.100',
        protocol: 'TCP',
        port: 22,
        size: 1200,
        flags: 'PSH,ACK',
        payload: 'SSH connection attempt',
        suspicious: true,
      ),
      NetworkPacket(
        id: 3,
        timestamp: '10:00:03',
        sourceIP: '10.0.0.1',
        destIP: '192.168.1.100',
        protocol: 'UDP',
        port: 53,
        size: 512,
        flags: 'N/A',
        payload: 'DNS query for malicious-domain.com',
        suspicious: true,
      ),
      NetworkPacket(
        id: 4,
        timestamp: '10:00:04',
        sourceIP: '192.168.1.100',
        destIP: '1.1.1.1',
        protocol: 'TCP',
        port: 80,
        size: 800,
        flags: 'GET',
        payload: 'HTTP request to legitimate site',
        suspicious: false,
      ),
      NetworkPacket(
        id: 5,
        timestamp: '10:00:05',
        sourceIP: '192.168.1.50',
        destIP: '192.168.1.100',
        protocol: 'TCP',
        port: 4444,
        size: 2000,
        flags: 'PSH,ACK',
        payload: 'Large data transfer to suspicious port',
        suspicious: true,
      ),
    ]);
    
    _filteredPackets.addAll(_packets);
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      switch (filter) {
        case 'all':
          _filteredPackets.clear();
          _filteredPackets.addAll(_packets);
          break;
        case 'suspicious':
          _filteredPackets.clear();
          _filteredPackets.addAll(_packets.where((p) => p.suspicious));
          break;
        case 'tcp':
          _filteredPackets.clear();
          _filteredPackets.addAll(_packets.where((p) => p.protocol == 'TCP'));
          break;
        case 'udp':
          _filteredPackets.clear();
          _filteredPackets.addAll(_packets.where((p) => p.protocol == 'UDP'));
          break;
        case 'large':
          _filteredPackets.clear();
          _filteredPackets.addAll(_packets.where((p) => p.size > 1000));
          break;
      }
    });
  }

  void _showPacketDetail(NetworkPacket packet) {
    setState(() {
      _selectedPacket = packet;
      _showPacketDetails = true;
    });
  }

  void _analyzeTraffic() {
    final suspiciousCount = _packets.where((p) => p.suspicious).length;
    final totalPackets = _packets.length;
    
    if (suspiciousCount >= 2) {
      completeMission();
      showSuccessAndExit();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Found $suspiciousCount suspicious packets. Need at least 2 to complete mission.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget buildMissionContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Column(
        children: [
        // Mission Description
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Web Traffic Analysis Lab',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryPurple,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Analyze network traffic to identify suspicious activity. '
                  'Look for unusual connections, large data transfers, and suspicious payloads.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Identify at least 2 suspicious packets to complete the mission',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Filter Controls
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Traffic Filters',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'all',
                    'suspicious',
                    'tcp',
                    'udp',
                    'large',
                  ].map((filter) => FilterChip(
                    label: Text(filter.toUpperCase()),
                    selected: _selectedFilter == filter,
                    onSelected: (selected) {
                      if (selected) {
                        _applyFilter(filter);
                      }
                    },
                    selectedColor: AppTheme.primaryPurple.withOpacity(0.2),
                    checkmarkColor: AppTheme.primaryPurple,
                  )).toList(),
                ),
              ],
            ),
          ),
        ),

        // Packet List
        Card(
          margin: const EdgeInsets.all(16),
          child: Column(
            children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Network Packets (${_filteredPackets.length})',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _analyzeTraffic,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryPurple,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Analyze Traffic'),
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredPackets.length,
                  itemBuilder: (context, index) {
                    final packet = _filteredPackets[index];
                    return PacketListItem(
                      packet: packet,
                      onTap: () => _showPacketDetail(packet),
                    );
                  },
                ),
              ],
            ),
          ),

        // Packet Details Modal
        if (_showPacketDetails && _selectedPacket != null)
          _buildPacketDetailsModal(),
      ],
    ),
    );
  }

  Widget _buildPacketDetailsModal() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Packet Details',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showPacketDetails = false;
                            _selectedPacket = null;
                          });
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('ID', _selectedPacket!.id.toString()),
                        _buildDetailRow('Timestamp', _selectedPacket!.timestamp),
                        _buildDetailRow('Source IP', _selectedPacket!.sourceIP),
                        _buildDetailRow('Destination IP', _selectedPacket!.destIP),
                        _buildDetailRow('Protocol', _selectedPacket!.protocol),
                        _buildDetailRow('Port', _selectedPacket!.port.toString()),
                        _buildDetailRow('Size', '${_selectedPacket!.size} bytes'),
                        _buildDetailRow('Flags', _selectedPacket!.flags),
                        _buildDetailRow('Payload', _selectedPacket!.payload),
                        _buildDetailRow('Suspicious', _selectedPacket!.suspicious ? 'Yes' : 'No'),
                        if (_selectedPacket!.suspicious)
                          Container(
                            margin: const EdgeInsets.only(top: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning, color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'This packet shows suspicious activity and should be investigated further.',
                                    style: TextStyle(color: Colors.red[700]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PacketListItem extends StatelessWidget {
  final NetworkPacket packet;
  final VoidCallback onTap;

  const PacketListItem({
    super.key,
    required this.packet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: packet.suspicious ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          packet.suspicious ? Icons.warning : Icons.check_circle,
          color: packet.suspicious ? Colors.red : Colors.green,
        ),
      ),
      title: Text(
        '${packet.sourceIP} → ${packet.destIP}',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: 'monospace',
        ),
      ),
      subtitle: Text(
        '${packet.protocol}:${packet.port} | ${packet.size} bytes | ${packet.timestamp}',
        style: TextStyle(
          color: Colors.grey[600],
          fontFamily: 'monospace',
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: packet.suspicious ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          packet.suspicious ? 'SUSPICIOUS' : 'NORMAL',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: packet.suspicious ? Colors.red : Colors.green,
          ),
        ),
      ),
    );
  }
}

class NetworkPacket {
  final int id;
  final String timestamp;
  final String sourceIP;
  final String destIP;
  final String protocol;
  final int port;
  final int size;
  final String flags;
  final String payload;
  final bool suspicious;

  NetworkPacket({
    required this.id,
    required this.timestamp,
    required this.sourceIP,
    required this.destIP,
    required this.protocol,
    required this.port,
    required this.size,
    required this.flags,
    required this.payload,
    required this.suspicious,
  });
}
