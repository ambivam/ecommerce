package com.ecommerce.controller;

import com.ecommerce.model.Order;
import com.ecommerce.model.OrderStatus;
import com.ecommerce.service.OrderService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.List;
import java.util.Optional;

/**
 * REST Controller for Order operations
 */
@Path("/orders")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class OrderController {
    private static final Logger logger = LoggerFactory.getLogger(OrderController.class);
    private final OrderService orderService;

    public OrderController() {
        this.orderService = new OrderService();
    }

    /**
     * Get all orders
     */
    @GET
    public Response getAllOrders() {
        try {
            List<Order> orders = orderService.getAllOrders();
            return Response.ok(orders).build();
        } catch (Exception e) {
            logger.error("Error retrieving orders", e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Failed to retrieve orders\"}")
                    .build();
        }
    }

    /**
     * Get order by ID
     */
    @GET
    @Path("/{id}")
    public Response getOrderById(@PathParam("id") Long id) {
        try {
            Optional<Order> order = orderService.getOrderById(id);
            if (order.isPresent()) {
                return Response.ok(order.get()).build();
            } else {
                return Response.status(Response.Status.NOT_FOUND)
                        .entity("{\"error\":\"Order not found\"}")
                        .build();
            }
        } catch (Exception e) {
            logger.error("Error retrieving order by ID: {}", id, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Failed to retrieve order\"}")
                    .build();
        }
    }

    /**
     * Get orders by user ID
     */
    @GET
    @Path("/user/{userId}")
    public Response getOrdersByUserId(@PathParam("userId") Long userId) {
        try {
            List<Order> orders = orderService.getOrdersByUserId(userId);
            return Response.ok(orders).build();
        } catch (Exception e) {
            logger.error("Error retrieving orders by user ID: {}", userId, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Failed to retrieve orders\"}")
                    .build();
        }
    }

    /**
     * Get orders by status
     */
    @GET
    @Path("/status/{status}")
    public Response getOrdersByStatus(@PathParam("status") String statusStr) {
        try {
            OrderStatus status = OrderStatus.valueOf(statusStr.toUpperCase());
            List<Order> orders = orderService.getOrdersByStatus(status);
            return Response.ok(orders).build();
        } catch (IllegalArgumentException e) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\":\"Invalid order status: " + statusStr + "\"}")
                    .build();
        } catch (Exception e) {
            logger.error("Error retrieving orders by status: {}", statusStr, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Failed to retrieve orders\"}")
                    .build();
        }
    }

    /**
     * Create new order
     */
    @POST
    public Response createOrder(Order order) {
        try {
            if (order == null) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\":\"Order data is required\"}")
                        .build();
            }

            if (order.getUserId() == null) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\":\"User ID is required\"}")
                        .build();
            }

            if (order.getTotalAmount() == null || order.getTotalAmount().signum() <= 0) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\":\"Valid total amount is required\"}")
                        .build();
            }

            Order createdOrder = orderService.createOrder(order);
            return Response.status(Response.Status.CREATED)
                    .entity(createdOrder)
                    .build();
        } catch (Exception e) {
            logger.error("Error creating order", e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Failed to create order\"}")
                    .build();
        }
    }

    /**
     * Update order
     */
    @PUT
    @Path("/{id}")
    public Response updateOrder(@PathParam("id") Long id, Order order) {
        try {
            if (order == null) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\":\"Order data is required\"}")
                        .build();
            }

            order.setId(id);
            Order updatedOrder = orderService.updateOrder(order);
            return Response.ok(updatedOrder).build();
        } catch (IllegalArgumentException e) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\":\"" + e.getMessage() + "\"}")
                    .build();
        } catch (Exception e) {
            logger.error("Error updating order: {}", id, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Failed to update order\"}")
                    .build();
        }
    }

    /**
     * Update order status
     */
    @PUT
    @Path("/{id}/status/{status}")
    public Response updateOrderStatus(@PathParam("id") Long id, @PathParam("status") String statusStr) {
        try {
            OrderStatus status = OrderStatus.valueOf(statusStr.toUpperCase());
            orderService.updateOrderStatus(id, status);
            return Response.ok("{\"message\":\"Order status updated successfully\"}").build();
        } catch (IllegalArgumentException e) {
            if (e.getMessage().contains("Order not found")) {
                return Response.status(Response.Status.NOT_FOUND)
                        .entity("{\"error\":\"" + e.getMessage() + "\"}")
                        .build();
            } else {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\":\"Invalid order status: " + statusStr + "\"}")
                        .build();
            }
        } catch (Exception e) {
            logger.error("Error updating order status: {}", id, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Failed to update order status\"}")
                    .build();
        }
    }

    /**
     * Cancel order
     */
    @PUT
    @Path("/{id}/cancel")
    public Response cancelOrder(@PathParam("id") Long id) {
        try {
            orderService.cancelOrder(id);
            return Response.ok("{\"message\":\"Order cancelled successfully\"}").build();
        } catch (IllegalArgumentException e) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\":\"" + e.getMessage() + "\"}")
                    .build();
        } catch (IllegalStateException e) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\":\"" + e.getMessage() + "\"}")
                    .build();
        } catch (Exception e) {
            logger.error("Error cancelling order: {}", id, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Failed to cancel order\"}")
                    .build();
        }
    }

    /**
     * Ship order
     */
    @PUT
    @Path("/{id}/ship")
    public Response shipOrder(@PathParam("id") Long id) {
        try {
            orderService.shipOrder(id);
            return Response.ok("{\"message\":\"Order shipped successfully\"}").build();
        } catch (IllegalArgumentException e) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\":\"" + e.getMessage() + "\"}")
                    .build();
        } catch (IllegalStateException e) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\":\"" + e.getMessage() + "\"}")
                    .build();
        } catch (Exception e) {
            logger.error("Error shipping order: {}", id, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Failed to ship order\"}")
                    .build();
        }
    }

    /**
     * Mark order as delivered
     */
    @PUT
    @Path("/{id}/deliver")
    public Response deliverOrder(@PathParam("id") Long id) {
        try {
            orderService.deliverOrder(id);
            return Response.ok("{\"message\":\"Order delivered successfully\"}").build();
        } catch (IllegalArgumentException e) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\":\"" + e.getMessage() + "\"}")
                    .build();
        } catch (IllegalStateException e) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\":\"" + e.getMessage() + "\"}")
                    .build();
        } catch (Exception e) {
            logger.error("Error delivering order: {}", id, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Failed to deliver order\"}")
                    .build();
        }
    }

    /**
     * Delete order
     */
    @DELETE
    @Path("/{id}")
    public Response deleteOrder(@PathParam("id") Long id) {
        try {
            orderService.deleteOrder(id);
            return Response.ok("{\"message\":\"Order deleted successfully\"}").build();
        } catch (IllegalArgumentException e) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\":\"" + e.getMessage() + "\"}")
                    .build();
        } catch (IllegalStateException e) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\":\"" + e.getMessage() + "\"}")
                    .build();
        } catch (Exception e) {
            logger.error("Error deleting order: {}", id, e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Failed to delete order\"}")
                    .build();
        }
    }
}
