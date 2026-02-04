import 'package:flutter/material.dart';

class ProsConsSection extends StatelessWidget {
  final List<String> pros;
  final List<String> cons;

  const ProsConsSection({
    Key? key,
    required this.pros,
    required this.cons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🤖 AI Analysis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            
            // PROS Section
            if (pros.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.thumb_up, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Pros',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              ...pros.map((pro) => Padding(
                padding: EdgeInsets.only(left: 28, bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: Colors.green)),
                    Expanded(child: Text(pro)),
                  ],
                ),
              )),
              SizedBox(height: 16),
            ],
            
            // CONS Section
            if (cons.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.thumb_down, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Cons',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              ...cons.map((con) => Padding(
                padding: EdgeInsets.only(left: 28, bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: Colors.red)),
                    Expanded(child: Text(con)),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}
