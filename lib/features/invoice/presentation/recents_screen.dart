import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../logic/dependency_provider.dart';
import '../../../presentation/theme/app_theme.dart';
import '../logic/invoice_list_controller.dart';
import '../models/invoice.dart';
import '../widgets/status_chip.dart';
import 'invoice_details_screen.dart';

class RecentsScreen extends StatefulWidget {
  const RecentsScreen({super.key});

  @override
  State<RecentsScreen> createState() => _RecentsScreenState();
}

class _RecentsScreenState extends State<RecentsScreen> {
  late InvoiceListController _listController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final FocusNode _focusNode = FocusNode();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _listController = DependencyProvider.of(context).listController;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recents'),
        // actions: [
        //   IconButton(
        //     onPressed: () {},
        //     icon: const Icon(Icons.filter_list, color: AppColors.textHeader),
        //   ),
        // ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20.r),
            child: TextField(
              focusNode: _focusNode,
              onTapOutside: (event) {
                _focusNode.unfocus();
              },
              onSubmitted: (val) {
                _focusNode.unfocus();
              },
              onEditingComplete: () {
                _focusNode.unfocus();
              },
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search by client or invoice #',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.r),
              ),
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: _listController,
              builder: (context, _) {
                final invoices = _listController.invoices.where((i) {
                  final query = _searchQuery.toLowerCase();
                  return i.clientName.toLowerCase().contains(query) ||
                      i.invoiceNumber.toLowerCase().contains(query);
                }).toList();

                if (invoices.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64.r,
                          color: Colors.grey.shade300,
                        ),
                        16.verticalSpace,
                        Text(
                          'No invoices found',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView(
                  padding: EdgeInsets.symmetric(horizontal: 20.r),
                  children: [
                    _buildSectionHeader('YOUR INVOICES'),
                    12.verticalSpace,
                    ...invoices.map((i) => _buildInvoiceItem(i)),
                    100.verticalSpace,
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textBody,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildInvoiceItem(Invoice invoice) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InvoiceDetailsScreen(invoice: invoice),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.r),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48.r,
              height: 48.r,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Text(
                  invoice.clientName.isNotEmpty
                      ? invoice.clientName.substring(0, 1).toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
              ),
            ),
            16.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          invoice.clientName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      8.horizontalSpace,
                      StatusChip(status: invoice.status),
                    ],
                  ),
                  4.verticalSpace,
                  Text(
                    '${invoice.invoiceNumber} • ${DateFormat('MMM dd, yyyy').format(invoice.date)}',
                    style: TextStyle(
                      color: AppColors.textBody,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${invoice.grandTotal.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  'INR',
                  style: TextStyle(color: AppColors.textBody, fontSize: 10.sp),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
